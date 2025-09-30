// frontend/src/App.tsx
import { LogForm } from './LogForm';
import { LogList } from './LogList';

function App() {
  return (
    <div>
      <h1>Welcome to your Personal System!</h1>
      <LogForm />
      <LogList />
    </div>
  );
}

export default App;