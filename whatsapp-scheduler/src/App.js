import React, { useState } from 'react';
import ScheduleForm from './components/ScheduleForm';
import NotificationList from './components/NotificationList';
import './App.css';

function App() {
  const [refresh, setRefresh] = useState(0);

  const handleNotificationScheduled = () => {
    setRefresh(refresh + 1);
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>WhatsApp Notification Scheduler</h1>
      </header>
      <div className="container">
        <ScheduleForm onNotificationScheduled={handleNotificationScheduled} />
        <NotificationList refresh={refresh} />
      </div>
    </div>
  );
}

export default App;
