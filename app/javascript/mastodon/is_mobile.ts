import { supportsPassiveEvents } from 'detect-passive-events';

import { forceSingleColumn, hasMultiColumnPath } from './initial_state';

const LAYOUT_BREAKPOINT = 630;

export const isMobile = (width: number) => width <= LAYOUT_BREAKPOINT;

// If the screen smaller than this, label of side panel is hidden.
// Taken from app/javascript/styles/mastodon/components.scss
const SMALL_SCREEN_THRESHOLD = 1175 - 285 - 1;
export const isSmallScreen = (width: number) => width <= SMALL_SCREEN_THRESHOLD;

export const transientSingleColumn = !forceSingleColumn && !hasMultiColumnPath;

export type LayoutType = 'mobile' | 'single-column' | 'multi-column';
export const layoutFromWindow = (): LayoutType => {
  if (isMobile(window.innerWidth)) {
    return 'mobile';
  } else if (!forceSingleColumn && !transientSingleColumn) {
    return 'multi-column';
  } else {
    return 'single-column';
  }
};

const listenerOptions = supportsPassiveEvents ? { passive: true } : false;

let userTouching = false;

const touchListener = () => {
  userTouching = true;

  window.removeEventListener('touchstart', touchListener);
};

window.addEventListener('touchstart', touchListener, listenerOptions);

export const isUserTouching = () => userTouching;
