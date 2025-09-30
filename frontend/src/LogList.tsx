// frontend/src/LogList.tsx
import { useListLogsQuery } from './state/generatedApi';

export function LogList() {
  // This single hook manages the entire data fetching lifecycle!
  const { data: logs, error, isLoading } = useListLogsQuery();

  return (
    <div style={{ marginTop: '2em' }}>
      <h3>All Log Entries</h3>
      
      {isLoading && <p>Loading logs...</p>}

      {error && <p>Error fetching logs.</p>}

      {logs && logs.length === 0 && (
        <p>No logs found. Add one using the form above!</p>
      )}

      <ul>
        {logs?.map((log) => (
          <li key={log._id} style={{ borderBottom: '1px solid #ccc', padding: '8px 0' }}>
            <strong>Mood: {log.mood}/5</strong> - {log.content}
          </li>
        ))}
      </ul>
    </div>
  );
}