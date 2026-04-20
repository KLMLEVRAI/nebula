import React, { useState, useRef, useEffect } from 'react';
import { Send, User, Bot, Trash2 } from 'lucide-react';
import { streamGroq } from '../lib/groq';

const Chat = () => {
  const [messages, setMessages] = useState(() => {
    const saved = localStorage.getItem('nebula_history');
    return saved ? JSON.parse(saved) : [];
  });
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
    localStorage.setItem('nebula_history', JSON.stringify(messages));
  }, [messages]);

  const handleSend = async () => {
    if (!input.trim() || isLoading) return;

    const config = JSON.parse(localStorage.getItem('nebula_settings') || '{}');
    const apiKey = config.apiKey || ''; // Removed hardcoded key for security

    const userMessage = { role: 'user', content: input };
    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setIsLoading(true);

    let assistantMessage = { role: 'assistant', content: '' };
    setMessages(prev => [...prev, assistantMessage]);

    try {
      await streamGroq({
        messages: [...messages, userMessage],
        model: config.model || 'llama-3.1-8b-instant',
        temperature: config.temperature || 0.7,
        apiKey: apiKey,
        onToken: (token) => {
          setMessages(prev => {
            const newMessages = [...prev];
            newMessages[newMessages.length - 1].content += token;
            return newMessages;
          });
        }
      });
    } catch (error) {
      console.error(error);
      setMessages(prev => {
        const newMessages = [...prev];
        newMessages[newMessages.length - 1].content = `Error: ${error.message}`;
        return newMessages;
      });
    } finally {
      setIsLoading(false);
    }
  };

  const clearHistory = () => {
    if (window.confirm('Clear conversation?')) {
      setMessages([]);
      localStorage.removeItem('nebula_history');
    }
  };

  return (
    <div className="chat-container fade-in">
      <header className="chat-header">
        <h1>Nebula</h1>
        <button className="clear-btn" onClick={clearHistory}>
          <Trash2 size={18} />
        </button>
      </header>

      <div className="messages-area">
        {messages.length === 0 && (
          <div className="empty-state">
            <h2 className="scale-in">How can I help you today?</h2>
          </div>
        )}
        {messages.map((msg, i) => (
          <div key={i} className={`message-wrapper ${msg.role}`}>
            <div className={`message-bubble ${msg.role === 'user' ? 'user-bubble' : 'bot-bubble glass'}`}>
              {msg.content}
            </div>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      <div className="input-area">
        <div className="input-wrapper glass">
          <input 
            type="text" 
            value={input} 
            onChange={(e) => setInput(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSend()}
            placeholder="Talk to Nebula..."
            disabled={isLoading}
          />
          <button className="send-btn" onClick={handleSend} disabled={isLoading || !input.trim()}>
            <Send size={20} />
          </button>
        </div>
      </div>

    </div>
  );
};

export default Chat;
