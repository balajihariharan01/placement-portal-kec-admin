import axios, { AxiosError, InternalAxiosRequestConfig } from 'axios';
import { APP_CONFIG } from '@/constants/config';
import { toast } from 'sonner';

// API Configuration
const API_TIMEOUT = 30000; // 30 seconds
const MAX_RETRIES = 3;
const RETRY_DELAY = 1000; // 1 second

// Ensure HTTPS in production
const getBaseURL = () => {
  const url = APP_CONFIG.API_BASE_URL;

  // Force HTTPS in production
  if (process.env.NEXT_PUBLIC_APP_ENV === 'production' && url.startsWith('http://')) {
    console.warn('⚠️ Converting HTTP to HTTPS for production environment');
    return url.replace('http://', 'https://');
  }

  return url;
};

// Create axios instance with production-ready configuration
const api = axios.create({
  baseURL: getBaseURL(),
  timeout: API_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
  },
  // Ensure credentials are sent with requests (for cookies if needed)
  withCredentials: false, // Set to true if using cookies for auth
});

// Request interceptor - Add auth token and logging
api.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    // Log the request for debugging
    console.log(`[API Request] ${config.method?.toUpperCase()} ${config.url}`, config.data || '');

    // Add Authorization header if token exists
    const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null;
    if (token && config.headers) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }

    // Add timestamp for request tracking
    config.headers['X-Request-Time'] = new Date().toISOString();

    return config;
  },
  (error: AxiosError) => {
    console.error('[API Request Error]', error);
    return Promise.reject(error);
  }
);

// Response interceptor - Handle errors and retries
api.interceptors.response.use(
  (response) => {
    // Log successful responses
    console.log(`[API Response] ${response.status} ${response.config.url}`, response.data);
    return response;
  },
  async (error: AxiosError) => {
    const config = error.config as InternalAxiosRequestConfig & { _retry?: number };

    // Use console.warn instead of console.error to avoid triggering Next.js error overlay
    console.warn('[API Response Warning]', error.response?.status, error.response?.data);

    const status = error.response?.status;
    const errorMessage = (error.response?.data as any)?.error || (error.response?.data as any)?.message;

    // Handle different error scenarios
    if (status === 401 || status === 403) {
      // Authentication/Authorization errors
      toast.error('Invalid credentials or session expired');

      // Optional: Clear auth state and redirect to login
      if (typeof window !== 'undefined') {
        localStorage.removeItem('token');
        // Only redirect if not already on login page
        if (!window.location.pathname.includes('/login')) {
          setTimeout(() => {
            window.location.href = '/login';
          }, 1500);
        }
      }
    } else if (status === 404) {
      toast.error('Resource not found');
    } else if (status === 422) {
      toast.error('Validation error: ' + errorMessage);
    } else if (status === 429) {
      toast.error('Too many requests. Please slow down.');
    } else if (status && status >= 500) {
      // Server errors - attempt retry
      const retryCount = config._retry || 0;

      if (retryCount < MAX_RETRIES) {
        config._retry = retryCount + 1;

        // Wait before retrying with exponential backoff
        await new Promise(resolve => setTimeout(resolve, RETRY_DELAY * Math.pow(2, retryCount)));

        console.log(`[API Retry] Attempt ${config._retry} for ${config.url}`);
        return api(config);
      }

      toast.error('Server error. Please try again later.');
    } else if (error.code === 'ERR_NETWORK' || error.code === 'ECONNABORTED') {
      // Network errors
      toast.error('Network error. Please check your connection.');
    } else if (error.code === 'ETIMEDOUT' || error.message.includes('timeout')) {
      // Timeout errors
      toast.error('Request timeout. Please try again.');
    } else {
      // Generic error
      toast.error(errorMessage || 'An error occurred');
    }

    // Return a rejected promise with error info
    return Promise.reject({
      handled: true,
      status,
      message: errorMessage,
      originalError: error
    });
  }
);

// Health check function
export const checkAPIHealth = async (): Promise<boolean> => {
  try {
    const response = await api.get('/health', { timeout: 5000 });
    return response.status === 200;
  } catch (error) {
    console.error('[API Health Check Failed]', error);
    return false;
  }
};

export default api;

