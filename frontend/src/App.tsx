// frontend/src/App.tsx
import { LogForm } from './LogForm';
import { LogList } from './LogList';
import { DataImporter } from './DataImporter';
import { TimeLogList } from './TimeLogList';

function App() {
  return (
    <div>
      <h1>Welcome to your Personal System!</h1>
      <DataImporter />
      <hr />
      <LogForm />
      <LogList />
      <TimeLogList />
    </div>
  );
}

export default App;