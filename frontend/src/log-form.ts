// frontend/src/log-form.ts

export class LogForm {
  // This property will be linked to the <textarea> in our HTML.
  public logContent: string = '';

  // This is the URL of your local FastAPI server.
  private apiUrl = 'http://127.0.0.1:8000/logs/';

  /**
   * This method is called when the form is submitted.
   */
  public async submitLog() {
    // Don't submit if the text area is empty.
    if (!this.logContent.trim()) {
      alert('Log content cannot be empty.');
      return;
    }

    // The API expects an object with 'content' and 'mood'.
    // For now, we'll hardcode the mood.
    const logData = {
      content: this.logContent,
      mood: 4, // Placeholder mood value (1-5)
    };

    try {
      const response = await fetch(this.apiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(logData),
      });

      if (!response.ok) {
        // If the server responds with an error, show it.
        throw new Error(`HTTP error! Status: ${response.status}`);
      }

      console.log('Log submitted successfully!');
      
      // Clear the text area for the next entry.
      this.logContent = '';

    } catch (error) {
      console.error('Failed to submit log:', error);
      alert('There was an error submitting your log. Please check the console.');
    }
  }
}