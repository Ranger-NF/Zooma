import { Room } from '../models';

/**
 * Generate a unique room code
 */
export const generateRoomCode = async (): Promise<string> => {
  let roomCode: string;
  let isUnique = false;
  let attempts = 0;
  const maxAttempts = 10;

  while (!isUnique && attempts < maxAttempts) {
    roomCode = Math.random().toString(36).substring(2, 8).toUpperCase();
    
    try {
      const existingRoom = await Room.findOne({ roomCode });
      if (!existingRoom) {
        isUnique = true;
        return roomCode;
      }
    } catch (error) {
      console.error('Error checking room code uniqueness:', error);
    }
    
    attempts++;
  }

  throw new Error('Failed to generate unique room code after maximum attempts');
};

/**
 * Generate a unique task ID
 */
export const generateTaskId = (): string => {
  return Date.now().toString() + Math.random().toString(36).substr(2, 9);
};

/**
 * Validate room code format
 */
export const isValidRoomCode = (roomCode: string): boolean => {
  return /^[A-Z0-9]{6}$/.test(roomCode);
};

/**
 * Validate player name
 */
export const isValidPlayerName = (name: string): boolean => {
  return (
    !!name && name.trim().length >= 2 && name.trim().length <= 50
  );
};


/**
 * Sanitize string input
 */
export const sanitizeString = (input: string): string => {
  return input.trim().replace(/[<>]/g, '');
};

/**
 * Calculate percentage completion
 */
export const calculateCompletionPercentage = (completed: number, total: number): number => {
  if (total === 0) return 0;
  return Math.round((completed / total) * 100);
};

/**
 * Format points display
 */
export const formatPoints = (points: number): string => {
  if (points >= 1000) {
    return (points / 1000).toFixed(1) + 'k';
  }
  return points.toString();
};

// Check if file exists
export const fileExists = (filePath: string): Promise<boolean> => {
  return new Promise((resolve) => {
    const fs = require('fs');
    fs.access(filePath, fs.constants.F_OK, (err: any) => {
      resolve(!err);
    });
  });
};

/**
 * Get file extension from mimetype
 */
export const getFileExtension = (mimetype: string): string => {
  const extensions: { [key: string]: string } = {
    'image/jpeg': '.jpg',
    'image/jpg': '.jpg',
    'image/png': '.png',
    'image/gif': '.gif',
    'image/webp': '.webp'
  };
  return extensions[mimetype] || '.jpg';
};

/**
 * Validate task data
 */
export const validateTaskData = (task: any): boolean => {
  return (
    task &&
    typeof task.title === 'string' &&
    task.title.trim().length > 0 &&
    typeof task.description === 'string' &&
    task.description.trim().length > 0 &&
    typeof task.points === 'number' &&
    task.points > 0
  );
};

/**
 * Create standardized API response
 */
export const createApiResponse = <T>(
  success: boolean,
  data?: T,
  message?: string,
  error?: string
) => {
  return {
    success,
    ...(data && { data }),
    ...(message && { message }),
    ...(error && { error })
  };
};

/**
 * Delay function for rate limiting or testing
 */
export const delay = (ms: number): Promise<void> => {
  return new Promise(resolve => setTimeout(resolve, ms));
};

/**
 * Generate random string
 */
export const generateRandomString = (length: number = 10): string => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};