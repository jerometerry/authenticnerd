// frontend/src/log-list.ts

// It's good practice to define an interface for the shape of our data.
// This gives us type safety and autocompletion.
interface ILog {
  id: string;
  content: string;
  mood: number;
}

export class LogList {
  // This array will hold the log entries fetched from the API.
  public logs: ILog[] = [];
  private apiUrl = 'http://127.0.0.1:8000/logs/';

  /**
   * This is an Aurelia lifecycle hook.
   * It's called automatically when the component is being added to the page.
   * It's the perfect place to fetch initial data.
   */
  public async attaching() {
    try {
      const response = await fetch(this.apiUrl);
      if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
      }
      // Parse the JSON response and store it in our 'logs' array.
      this.logs = await response.json();
      console.log('Logs fetched successfully!', this.logs);

    } catch (error) {
      console.error('Failed to fetch logs:', error);
    }
  }
}