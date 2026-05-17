import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5001/api';

// Create axios instance
const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: false,
});

export const scheduleNotification = async (data) => {
  console.log('🚀 CLIENT: Calling scheduleNotification API');
  console.log('🚀 CLIENT: Request data:', data);
  console.log('🚀 CLIENT: API URL:', API_URL);
  try {
    const response = await apiClient.post('/notifications/schedule', data);
    console.log('✅ CLIENT: Schedule API success:', response.data);
    return response.data;
  } catch (error) {
    console.error('❌ CLIENT: Error scheduling notification:', error);
    console.error('❌ CLIENT: Error response:', error.response);
    console.error('❌ CLIENT: Error message:', error.message);
    throw error;
  }
};

export const getScheduledNotifications = async () => {
  console.log('🚀 CLIENT: Calling getScheduledNotifications API');
  try {
    const response = await apiClient.get('/notifications');
    console.log('✅ CLIENT: Get notifications success:', response.data);
    return response.data;
  } catch (error) {
    console.error('❌ CLIENT: Error fetching notifications:', error);
    console.error('❌ CLIENT: Error response:', error.response);
    throw error;
  }
};

export const cancelNotification = async (id) => {
  try {
    const response = await apiClient.delete(`/notifications/${id}`);
    return response.data;
  } catch (error) {
    console.error('Error canceling notification:', error);
    throw error;
  }
};