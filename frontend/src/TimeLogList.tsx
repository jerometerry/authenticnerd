interface TimeLogListProps {
  timeLogs: any[] | undefined;
  isLoading: boolean;
  error: any;
}

export function TimeLogList({ timeLogs, isLoading, error }: TimeLogListProps) {
  if (isLoading) return <p>Loading time logs...</p>;
  if (error) return <p>Error fetching time logs.</p>;

  return (
    <div style={{ marginTop: '2em' }}>
      <h3>Imported Time Log Entries</h3>
      <table style={{ width: '100%', borderCollapse: 'collapse' }}>
        {/* ... table structure remains the same ... */}
        <tbody>
          {timeLogs?.map((log) => (
            <tr key={log.id} style={{ borderBottom: '1px solid #ccc' }}>
              <td>{new Date(log.timestamp).toLocaleDateString()}</td>
              <td>{new Date(log.timestamp).toLocaleTimeString()}</td>
              <td>{log.activity}</td>
              <td>{log.core_values?.join(', ')}</td>
              <td>{log.intentionality}</td>
              <td>{log.energy}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}