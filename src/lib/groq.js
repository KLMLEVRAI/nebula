export const streamGroq = async ({ messages, model, temperature, max_tokens, apiKey, onToken }) => {
  const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: model || 'llama-3.1-8b-instant',
      messages,
      temperature: temperature ?? 0.7,
      max_tokens: max_tokens ?? 1024,
      stream: true,
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error?.message || 'Failed to stream from Groq');
  }

  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let done = false;

  while (!done) {
    const { value, done: doneReading } = await reader.read();
    done = doneReading;
    const chunkValue = decoder.decode(value);
    
    const lines = chunkValue.split('\n');
    for (const line of lines) {
      if (line.trim() === '' || line.trim() === 'data: [DONE]') continue;
      if (line.startsWith('data: ')) {
        const data = JSON.parse(line.substring(6));
        const content = data.choices[0]?.delta?.content;
        if (content) {
          onToken(content);
        }
      }
    }
  }
};
