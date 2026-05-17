import React, { useState, useEffect } from 'react';
import { getScheduledNotifications, cancelNotification } from '../api/api';

const NotificationList = ({ refresh }) => {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchNotifications();
  }, [refresh]);

  const fetchNotifications = async () => {
    setLoading(true);
    try {
      const data = await getScheduledNotifications();
      setNotifications(data);
    } catch (error) {
      console.error('Error fetching notifications:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = async (id) => {
    try {
      await cancelNotification(id);
      setNotifications(notifications.filter((n) => n.id !== id));
    } catch (error) {
      console.error('Error canceling notification:', error);
    }
  };

  return (
    <div className="notification-list">
      <h2>Scheduled Notifications</h2>
      {loading ? (
        <p>Loading...</p>
      ) : notifications.length > 0 ? (
        <table>
          <thead>
            <tr>
              <th>Phone Number</th>
              <th>Message</th>
              <th>Scheduled Time</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {notifications.map((notification) => (
              <tr key={notification.id}>
                <td>{notification.phoneNumber}</td>
                <td>{notification.message}</td>
                <td>{new Date(notification.scheduledTime).toLocaleString()}</td>
                <td>
                  <button onClick={() => handleCancel(notification.id)}>
                    Cancel
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      ) : (
        <p>No scheduled notifications</p>
      )}
    </div>
  );
};

export default NotificationList;
