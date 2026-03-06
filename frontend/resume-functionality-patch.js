/**
 * Enhanced UI - Resume Functionality Patch
 *
 * Add these methods and changes to the pipelineState() function in interview-ui-enhanced.html
 */

// ===== ADD TO STATE VARIABLES =====
// Add after existing state variables:
isResuming: false,
resumeError: null,
stateLoaded: false,

// ===== ADD NEW METHODS =====

/**
 * Load project state from API
 */
async loadProjectState(projectName) {
  try {
    const response = await fetch(`/webhook/api/pipeline-state/${projectName}`);
    const data = await response.json();

    if (data.exists && data.state) {
      return data.state;
    }
    return null;
  } catch (err) {
    console.error('Error loading project state:', err);
    return null;
  }
},

/**
 * Resume project from saved state
 */
async resumeProject(state) {
  this.projectName = state.project;
  this.currentPhase = state.currentPhase;
  this.stateLoaded = true;

  // Restore phase-specific state
  const currentPhaseData = state.phases[state.currentPhase];

  switch (state.currentPhase) {
    case 'interview':
      // Already completed, show last message
      if (currentPhaseData.status === 'completed') {
        this.addMsg('Interview completed. Transitioning...', 'agent');
        setTimeout(() => {
          this.currentPhase = 'synthesis';
          this.connectSSE();
        }, 1000);
      }
      break;

    case 'synthesis':
      this.progressPercent = currentPhaseData.progress || 0;
      this.progressMessage = currentPhaseData.progressMessage || 'Resuming...';

      if (currentPhaseData.status === 'in_progress') {
        this.connectSSE();
      } else if (currentPhaseData.status === 'completed') {
        setTimeout(() => {
          this.currentPhase = 'council';
          this.initializeCouncilReviews();
          this.connectSSE();
        }, 1000);
      }
      break;

    case 'council':
      this.initializeCouncilReviews();
      if (currentPhaseData.status === 'in_progress') {
        this.connectSSE();
      } else if (currentPhaseData.status === 'completed') {
        // Load findings
        setTimeout(() => {
          this.currentPhase = 'findings';
        }, 1000);
      }
      break;

    case 'findings':
      // Load findings from state if available
      break;
  }

  console.log(`✅ Resumed project: ${state.project} at phase ${state.currentPhase}`);
},

/**
 * Save project name to localStorage
 */
saveToLocalStorage() {
  try {
    localStorage.setItem('lastProject', this.projectName);
    localStorage.setItem('lastProjectTime', new Date().toISOString());
  } catch (err) {
    console.error('localStorage error:', err);
  }
},

/**
 * Load last project from localStorage
 */
loadFromLocalStorage() {
  try {
    const lastProject = localStorage.getItem('lastProject');
    const lastTime = localStorage.getItem('lastProjectTime');

    // Only resume if less than 24 hours old
    if (lastProject && lastTime) {
      const age = Date.now() - new Date(lastTime).getTime();
      if (age < 24 * 60 * 60 * 1000) {
        return lastProject;
      }
    }
  } catch (err) {
    console.error('localStorage error:', err);
  }
  return null;
},

// ===== UPDATE INIT() METHOD =====
/**
 * Replace the existing init() method with this enhanced version
 */
async init() {
  // Check URL for project parameter
  const urlParams = new URLSearchParams(window.location.search);
  const urlProject = urlParams.get('project');

  if (urlProject) {
    // Try to resume from URL project
    this.isResuming = true;
    this.projectName = urlProject;

    const state = await this.loadProjectState(urlProject);
    if (state) {
      await this.resumeProject(state);
      this.isResuming = false;
      return;
    } else {
      // Project doesn't exist, start fresh with this name
      this.isResuming = false;
      this.startInterview();
      return;
    }
  }

  // No URL parameter - check localStorage for recent project
  const lastProject = this.loadFromLocalStorage();
  if (lastProject) {
    const state = await this.loadProjectState(lastProject);
    if (state && state.currentPhase !== 'interview') {
      // Found recent project - offer to resume
      if (confirm(`Resume project "${lastProject}"?\n\nLast activity: ${new Date(state.lastUpdated).toLocaleString()}\nCurrent phase: ${state.currentPhase}`)) {
        this.isResuming = true;
        await this.resumeProject(state);
        this.isResuming = false;

        // Update URL
        window.history.replaceState({}, '', `?project=${lastProject}`);
        return;
      }
    }
  }

  // Generate new project name
  const now = new Date();
  const dateStr = now.toISOString().slice(0, 10);
  const timeStr = now.toTimeString().slice(0, 5).replace(':', '');
  this.projectName = `project-${dateStr}-${timeStr}`;

  // Save to localStorage
  this.saveToLocalStorage();

  // Start fresh interview
  this.startInterview();
},

// ===== UPDATE TRANSITION METHODS =====
/**
 * Update sendMessage() to save state after completion
 * Add this after setting this.interviewComplete = true:
 */
// Save to localStorage when interview completes
this.saveToLocalStorage();

/**
 * Update connectSSE() to save project on connection
 * Add at the start of connectSSE():
 */
this.saveToLocalStorage();

// ===== ADD LOADING UI =====
/**
 * Add this HTML before the main content (after <body x-data...>):
 */
/*
<div x-show="isResuming" class="phase-container" style="text-align: center;">
  <h3>🔄 Resuming Project</h3>
  <p>Loading state for <strong x-text="projectName"></strong>...</p>
  <div class="progress-bar-bg" style="width: 200px; margin: 20px auto;">
    <div class="progress-bar-fill" style="width: 100%; animation: pulse 1.5s infinite;"></div>
  </div>
</div>
*/

// ===== ADD CSS FOR LOADING ANIMATION =====
/*
@keyframes pulse {
  0%, 100% { opacity: 0.4; }
  50% { opacity: 1; }
}
*/
