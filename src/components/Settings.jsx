import React, { useState, useEffect } from 'react';
import { Shield, Palette, Zap, Database } from 'lucide-react';

const Settings = () => {
  const [settings, setSettings] = useState(() => {
    const saved = localStorage.getItem('nebula_settings');
    return saved ? JSON.parse(saved) : {
      model: 'llama-3.1-8b-instant',
      temperature: 0.7,
      blur: 24,
      animations: 0.6,
      apiKey: '',
      streaming: true,
      theme: 'classic'
    };
  });

  useEffect(() => {
    localStorage.setItem('nebula_settings', JSON.stringify(settings));
    // Apply UI settings globally
    document.documentElement.style.setProperty('--glass-blur', `${settings.blur}px`);
  }, [settings]);

  const handleChange = (key, value) => {
    setSettings(prev => ({ ...prev, [key]: value }));
  };

  return (
    <div className="settings-container fade-in">
      <header className="settings-header">
        <h1>Settings</h1>
      </header>

      <div className="settings-section">
        <div className="section-title"><Zap size={16} /> AI Engine</div>
        <div className="settings-group glass">
          <div className="setting-item">
            <span>Model</span>
            <select value={settings.model} onChange={(e) => handleChange('model', e.target.value)}>
              <option value="llama-3.1-8b-instant">Llama 3.1 8B</option>
              <option value="llama-3.1-70b-versatile">Llama 3.1 70B</option>
              <option value="mixtral-8x7b-32768">Mixtral 8x7B</option>
              <option value="gemma2-9b-it">Gemma 2 9B</option>
            </select>
          </div>
          <div className="setting-item">
            <span>Temperature ({settings.temperature})</span>
            <input 
              type="range" min="0" max="1" step="0.1" 
              value={settings.temperature} 
              onChange={(e) => handleChange('temperature', parseFloat(e.target.value))} 
            />
          </div>
          <div className="setting-item">
            <span>API Key</span>
            <input 
              type="password" 
              value={settings.apiKey} 
              onChange={(e) => handleChange('apiKey', e.target.value)}
              placeholder="Enter Groq Key..." 
            />
          </div>
        </div>
      </div>

      <div className="settings-section">
        <div className="section-title"><Palette size={16} /> Appearance</div>
        <div className="settings-group glass">
          <div className="setting-item">
            <span>Blur Intensity</span>
            <input 
              type="range" min="0" max="40" step="2" 
              value={settings.blur} 
              onChange={(e) => handleChange('blur', parseInt(e.target.value))} 
            />
          </div>
          <div className="setting-item">
            <span>Animation (s)</span>
            <input 
              type="range" min="0.1" max="1.5" step="0.1" 
              value={settings.animations} 
              onChange={(e) => handleChange('animations', parseFloat(e.target.value))} 
            />
          </div>
        </div>
      </div>

      <div className="settings-section">
        <div className="section-title"><Database size={16} /> Privacy & Data</div>
        <div className="settings-group glass">
          <div className="setting-item danger" onClick={() => {localStorage.clear(); window.location.reload();}}>
            <span>Reset All Data</span>
          </div>
        </div>
      </div>

    </div>
  );
};

export default Settings;
