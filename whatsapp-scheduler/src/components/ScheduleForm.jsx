import React, { useState } from 'react';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import { scheduleNotification } from '../api/api';

const ScheduleForm = ({ onNotificationScheduled }) => {
  const [formData, setFormData] = useState({
    phoneNumber: '',
    message: '',
    scheduledTime: new Date(),
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value,
    });
  };

  const handleDateChange = (date) => {
    setFormData({
      ...formData,
      scheduledTime: date,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Prevent double submission
    if (isSubmitting) {
      console.log('Already submitting, ignoring duplicate request');
      return;
    }

    setIsSubmitting(true);
    setLoading(true);
    setError('');
    setSuccess('');

    try {
      console.log('Submitting notification...');
      await scheduleNotification({
        ...formData,
        scheduledTime: formData.scheduledTime.toISOString(),
      });
      setSuccess('Notification scheduled successfully!');
      setFormData({
        phoneNumber: '',
        message: '',
        scheduledTime: new Date(),
      });
      onNotificationScheduled();
    } catch (err) {
      console.error('Submission error:', err);
      setError('Failed to schedule notification. Please try again.');
    } finally {
      setLoading(false);
      setIsSubmitting(false);
    }
  };

  return (
    <div className="schedule-form">
      <h2>Schedule WhatsApp Notification</h2>
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="phoneNumber">Phone Number (with country code)</label>
          <input
            type="text"
            id="phoneNumber"
            name="phoneNumber"
            value={formData.phoneNumber}
            onChange={handleInputChange}
            placeholder="+1234567890"
            required
          />
        </div>

        <div className="form-group">
          <label htmlFor="message">Message</label>
          <textarea
            id="message"
            name="message"
            value={formData.message}
            onChange={handleInputChange}
            placeholder="Enter your message"
            rows="4"
            required
          />
        </div>

        <div className="form-group">
          <label htmlFor="scheduledTime">Schedule Time</label>
          <DatePicker
            selected={formData.scheduledTime}
            onChange={handleDateChange}
            showTimeSelect
            timeFormat="HH:mm"
            dateFormat="yyyy-MM-dd HH:mm"
            minDate={new Date()}
          />
        </div>

        <button type="submit" disabled={loading}>
          {loading ? 'Scheduling...' : 'Schedule Notification'}
        </button>
      </form>

      {error && <div className="error-message">{error}</div>}
      {success && <div className="success-message">{success}</div>}
    </div>
  );
};

export default ScheduleForm;
