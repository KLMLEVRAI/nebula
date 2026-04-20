import React from 'react';
import { Sparkles, Code, PenTool, Globe, Lightbulb } from 'lucide-react';

const Explorer = () => {
  const prompts = [
    { title: 'Explain Quantum Physics', icon: <Sparkles size={20} />, category: 'Science' },
    { title: 'Write a React Hook', icon: <Code size={20} />, category: 'Coding' },
    { title: 'Creative Story Intro', icon: <PenTool size={20} />, category: 'Writing' },
    { title: 'Plan a Tokyo Trip', icon: <Globe size={20} />, category: 'Travel' },
    { title: 'Improve Social Skills', icon: <Lightbulb size={20} />, category: 'Lifestyle' }
  ];

  const handlePromptClick = (title) => {
    // In a real app, this would trigger the chat with the prompt
    alert(`Starting: ${title}`);
  };

  return (
    <div className="explorer-container fade-in">
      <header className="explorer-header">
        <h1>Explorer</h1>
        <p>Discover the power of Nebula</p>
      </header>

      <div className="prompt-grid">
        {prompts.map((p, i) => (
          <div key={i} className="prompt-card glass scale-in" style={{animationDelay: `${i * 0.1}s`}} onClick={() => handlePromptClick(p.title)}>
            <div className="icon-wrapper">{p.icon}</div>
            <div className="prompt-info">
              <h3>{p.title}</h3>
              <span>{p.category}</span>
            </div>
          </div>
        ))}
      </div>

    </div>
  );
};

export default Explorer;
