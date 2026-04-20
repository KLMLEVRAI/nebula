import React, { useState, useEffect } from 'react';
import { MessageSquare, Compass, Settings as SettingsIcon } from 'lucide-react';
import Chat from './components/Chat';
import Explorer from './components/Explorer';
import Settings from './components/Settings';

function App() {
  const [activeTab, setActiveTab] = useState('chat');
  
  return (
    <div className="app-container">
      {/* Background */}
      <div className="nebula-container">
        <div className="nebula-blob blob-1"></div>
        <div className="nebula-blob blob-2"></div>
        <div className="nebula-blob blob-3"></div>
      </div>

      {/* Main Content */}
      <main className="main-content">
        {activeTab === 'chat' && <Chat />}
        {activeTab === 'explorer' && <Explorer />}
        {activeTab === 'settings' && <Settings />}
      </main>

      {/* Navigation Tab Bar */}
      <nav className="tab-bar glass glass-shadow">
        <div 
          className={`tab-item ${activeTab === 'chat' ? 'active' : ''}`} 
          onClick={() => setActiveTab('chat')}
        >
          <MessageSquare size={24} />
          <span>Chat</span>
        </div>
        <div 
          className={`tab-item ${activeTab === 'explorer' ? 'active' : ''}`} 
          onClick={() => setActiveTab('explorer')}
        >
          <Compass size={24} />
          <span>Explorer</span>
        </div>
        <div 
          className={`tab-item ${activeTab === 'settings' ? 'active' : ''}`} 
          onClick={() => setActiveTab('settings')}
        >
          <SettingsIcon size={24} />
          <span>Config</span>
        </div>
      </nav>

    </div>
  );
}

export default App;
