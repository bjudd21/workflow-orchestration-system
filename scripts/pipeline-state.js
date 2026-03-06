/**
 * Pipeline State Management
 *
 * Utilities for reading/writing pipeline state to workspace/{project}/pipeline-state.json
 * Used by n8n workflows to track progress across phases.
 */

const fs = require('fs');
const path = require('path');

const WORKSPACE_ROOT = '/home/node/workspace';

/**
 * Get state file path for a project
 */
function getStatePath(project) {
  return path.join(WORKSPACE_ROOT, project, 'pipeline-state.json');
}

/**
 * Read current pipeline state
 * Returns null if state file doesn't exist
 */
function readState(project) {
  const statePath = getStatePath(project);
  if (!fs.existsSync(statePath)) {
    return null;
  }
  try {
    return JSON.parse(fs.readFileSync(statePath, 'utf8'));
  } catch (err) {
    console.error(`Error reading state for ${project}:`, err.message);
    return null;
  }
}

/**
 * Initialize state for a new project
 */
function initState(project) {
  const state = {
    project,
    currentPhase: 'interview',
    phases: {
      interview: { status: 'in_progress', startedAt: new Date().toISOString() },
      synthesis: { status: 'pending' },
      council: { status: 'pending' },
      findings: { status: 'pending' }
    },
    createdAt: new Date().toISOString(),
    lastUpdated: new Date().toISOString()
  };

  writeState(project, state);
  return state;
}

/**
 * Update phase status
 */
function updatePhase(project, phase, updates) {
  let state = readState(project);
  if (!state) {
    state = initState(project);
  }

  if (!state.phases[phase]) {
    state.phases[phase] = {};
  }

  Object.assign(state.phases[phase], updates);
  state.lastUpdated = new Date().toISOString();

  writeState(project, state);
  return state;
}

/**
 * Mark phase as completed
 */
function completePhase(project, phase, nextPhase = null) {
  const updates = {
    status: 'completed',
    completedAt: new Date().toISOString()
  };

  const state = updatePhase(project, phase, updates);

  if (nextPhase) {
    state.currentPhase = nextPhase;
    state.phases[nextPhase] = {
      status: 'in_progress',
      startedAt: new Date().toISOString()
    };
    writeState(project, state);
  }

  return state;
}

/**
 * Mark phase as failed
 */
function failPhase(project, phase, error) {
  return updatePhase(project, phase, {
    status: 'failed',
    failedAt: new Date().toISOString(),
    error: error
  });
}

/**
 * Update phase progress (for synthesis)
 */
function updateProgress(project, phase, percent, message = '') {
  return updatePhase(project, phase, {
    status: 'in_progress',
    progress: percent,
    progressMessage: message,
    lastProgressUpdate: new Date().toISOString()
  });
}

/**
 * Write state to disk
 */
function writeState(project, state) {
  const statePath = getStatePath(project);
  const dir = path.dirname(statePath);

  // Ensure directory exists
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  fs.writeFileSync(statePath, JSON.stringify(state, null, 2), 'utf8');
}

/**
 * Get all projects with their states
 * Used by dashboard
 */
function listProjects() {
  if (!fs.existsSync(WORKSPACE_ROOT)) {
    return [];
  }

  const projects = [];
  const dirs = fs.readdirSync(WORKSPACE_ROOT);

  for (const dir of dirs) {
    const projectPath = path.join(WORKSPACE_ROOT, dir);
    const statePath = path.join(projectPath, 'pipeline-state.json');

    if (fs.statSync(projectPath).isDirectory() && fs.existsSync(statePath)) {
      try {
        const state = JSON.parse(fs.readFileSync(statePath, 'utf8'));
        projects.push(state);
      } catch (err) {
        console.error(`Error reading state for ${dir}:`, err.message);
      }
    }
  }

  // Sort by lastUpdated, newest first
  projects.sort((a, b) => new Date(b.lastUpdated) - new Date(a.lastUpdated));

  return projects;
}

// Export for use in n8n Code nodes
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    readState,
    initState,
    updatePhase,
    completePhase,
    failPhase,
    updateProgress,
    writeState,
    listProjects
  };
}
