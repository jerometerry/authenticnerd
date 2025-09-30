import { LogForm } from './LogForm';
import { LogList } from './LogList';
import { DataImporter } from './DataImporter';
import { TimeLogList } from './TimeLogList';
import { useListLogsQuery, useListTimelogsQuery } from './state/generatedApi';

function App() {
  // 1. Fetch data for both lists here in the parent component
  const { data: logs, error: logsError, isLoading: logsLoading, refetch: refetchLogs } = useListLogsQuery();
  const { data: timeLogs, error: timeLogsError, isLoading: timeLogsLoading, refetch: refetchTimeLogs } = useListTimelogsQuery();

  // 2. Define a single callback function to refetch all data
  const handleSuccess = () => {
    console.log('Mutation successful, refetching lists...');
    refetchLogs();
    refetchTimeLogs();
  };

  return (
    <div>
      <h1>Welcome to your Personal System!</h1>
      {/* 3. Pass the callback to the form components */}
      <DataImporter onSuccess={handleSuccess} />
      <hr />
      {/* 4. Pass the data and loading states to the list components */}
      <TimeLogList timeLogs={timeLogs} isLoading={timeLogsLoading} error={timeLogsError} />
      <hr />
      <LogForm onSuccess={handleSuccess} />
      <LogList logs={logs} isLoading={logsLoading} error={logsError} />
    </div>
  );
}

export default App;