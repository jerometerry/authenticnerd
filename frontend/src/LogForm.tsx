import React, { useState } from 'react';
import { useCreateLogMutation } from './state/generatedApi';

// Define the props, including the callback
interface LogFormProps {
  onSuccess: () => void;
}

export function LogForm({ onSuccess }: LogFormProps) {
  const [content, setContent] = useState('');
  const [createLog, { isLoading }] = useCreateLogMutation();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!content.trim()) return;

    try {
      await createLog({ logEntry: { content, mood: 4 } }).unwrap();
      setContent('');
      onSuccess(); // Call the callback on success
    } catch (error) {
      console.error('Failed to create log:', error);
    }
  };

  // ... rest of the component's return statement is the same
  return (
    <form onSubmit={handleSubmit}>
      {/* ... */}
    </form>
  );
}