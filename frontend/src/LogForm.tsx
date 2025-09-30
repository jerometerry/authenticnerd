// frontend/src/LogForm.tsx
import React, { useState } from 'react';
import { useCreateLogLogsPostMutation } from './state/generatedApi';

export function LogForm() {
  
  const [content, setContent] = useState('');
  
  const [createLog, { isLoading }] = useCreateLogLogsPostMutation();


  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!content.trim()) return;

    try {
      // Call the trigger function with the log data
      await createLog({ logEntry: { content, mood: 4 } }).unwrap();
      // Clear the form on success
      setContent('');
    } catch (error) {
      console.error('Failed to create log:', error);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <h3>Add a New Log Entry</h3>
      <textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
        rows={5}
        placeholder="What's on your mind?"
        style={{ width: '100%', fontSize: '1em', padding: '8px' }}
        disabled={isLoading}
      />
      <button type="submit" disabled={isLoading}>
        {isLoading ? 'Submitting...' : 'Submit Log'}
      </button>
    </form>
  );
}