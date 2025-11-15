# Profanity Filter Service

The Profanity Filter Service provides configurable content moderation for chat messages in the Mind Wars application. It supports multiple strictness levels, per-lobby configurations, and dynamic word list management.

## Features

- **Multiple Strictness Levels**: Choose from strict, moderate, or relaxed filtering
- **Context-Specific Configurations**: Different settings per lobby or context
- **Dynamic Word Management**: Add/remove words at runtime without server restart
- **Singleton with Multiple Instances**: Efficiently manages multiple filter configurations
- **Comprehensive Testing**: Full test coverage for all features

## Strictness Levels

### STRICT (Family-Friendly)
- Filters all profanity including borderline words
- Additional words like "stupid", "idiot", "dumb" are filtered
- Recommended for family-oriented lobbies

### MODERATE (Default)
- Filters common profanity
- Balanced approach suitable for most use cases
- Default configuration if none specified

### RELAXED (Minimal Filtering)
- Only filters severe profanity
- Allows words like "hell", "damn", "crap"
- Suitable for casual adult lobbies

## Usage

### Basic Usage (Default Configuration)

```javascript
const profanityFilterService = require('./utils/profanityFilter');

// Filter a message with default configuration
const result = profanityFilterService.filterMessage('Your message here');
console.log(result.filtered);        // Filtered message
console.log(result.hasProfanity);    // true/false
console.log(result.strictness);      // Current strictness level
```

### Context-Specific Configuration

```javascript
const { STRICTNESS_LEVELS } = require('./utils/profanityFilter');

// Set configuration for a specific lobby
profanityFilterService.setConfiguration('lobby-123', {
  strictness: STRICTNESS_LEVELS.STRICT,
  customWords: ['gamingterm1', 'gamingterm2'],
  allowedWords: ['contextword']
});

// Filter with lobby context
const result = profanityFilterService.filterMessage('message', 'lobby-123');
```

### Dynamic Word Management

```javascript
// Add words to default filter
profanityFilterService.addWords('newword1', 'newword2');

// Remove words from default filter (for false positives)
profanityFilterService.removeWords('scunthorpe');

// Add words to specific context
profanityFilterService.addWordsToContext('lobby-123', 'gameterm1');

// Remove words from specific context
profanityFilterService.removeWordsFromContext('lobby-123', 'allowthis');
```

### Update Default Configuration

```javascript
// Change the default strictness level
profanityFilterService.updateDefaultConfiguration({
  strictness: STRICTNESS_LEVELS.STRICT,
  customWords: ['globalword1']
});
```

### Remove Context Configuration

```javascript
// When a lobby closes, clean up its configuration
profanityFilterService.removeConfiguration('lobby-123');
```

## API Reference

### Methods

#### `filterMessage(message, contextId)`
Filter a message and return filtered version with metadata.
- **Parameters:**
  - `message` (string): The message to filter
  - `contextId` (string, optional): Context identifier (e.g., lobby ID)
- **Returns:** Object with `filtered`, `hasProfanity`, `originalLength`, `strictness`

#### `isProfane(message, contextId)`
Check if a message contains profanity without filtering.
- **Parameters:**
  - `message` (string): The message to check
  - `contextId` (string, optional): Context identifier
- **Returns:** boolean

#### `clean(message, contextId)`
Clean a message by replacing profanity with asterisks.
- **Parameters:**
  - `message` (string): The message to clean
  - `contextId` (string, optional): Context identifier
- **Returns:** string (cleaned message)

#### `setConfiguration(contextId, options)`
Set configuration for a specific context.
- **Parameters:**
  - `contextId` (string): Context identifier
  - `options` (object): Configuration options
    - `strictness` (string): One of STRICTNESS_LEVELS
    - `customWords` (array): Custom words to filter
    - `allowedWords` (array): Words to exclude from filtering
- **Returns:** FilterConfig instance

#### `getConfiguration(contextId)`
Get configuration for a specific context.
- **Parameters:**
  - `contextId` (string): Context identifier
- **Returns:** FilterConfig instance (or default if not found)

#### `removeConfiguration(contextId)`
Remove configuration for a specific context.
- **Parameters:**
  - `contextId` (string): Context identifier

#### `updateDefaultConfiguration(options)`
Update the default configuration.
- **Parameters:**
  - `options` (object): Configuration options

#### `addWordsToContext(contextId, ...words)`
Add custom words to a specific context's filter.
- **Parameters:**
  - `contextId` (string): Context identifier
  - `words` (string...): Words to add

#### `removeWordsFromContext(contextId, ...words)`
Remove words from a specific context's filter.
- **Parameters:**
  - `contextId` (string): Context identifier
  - `words` (string...): Words to remove

#### `addWords(...words)`
Add words to the default filter.
- **Parameters:**
  - `words` (string...): Words to add

#### `removeWords(...words)`
Remove words from the default filter.
- **Parameters:**
  - `words` (string...): Words to remove

#### `getStrictnessLevels()`
Get available strictness levels.
- **Returns:** Object with STRICT, MODERATE, RELAXED properties

#### `clearCache()`
Clear all cached filter instances.

## Example: Per-Lobby Configuration

```javascript
// In your lobby creation handler
socket.on('create-lobby', async (data) => {
  const { name, strictness } = data;
  
  // Create lobby in database...
  const lobby = await createLobby(name);
  
  // Set profanity filter for this lobby
  profanityFilterService.setConfiguration(lobby.id, {
    strictness: strictness || STRICTNESS_LEVELS.MODERATE
  });
});

// In your chat handler
socket.on('chat-message', async (data) => {
  const { lobbyId, message } = data;
  
  // Apply lobby-specific filtering
  const filterResult = profanityFilterService.filterMessage(message, lobbyId);
  
  // Broadcast filtered message...
});

// When lobby closes
socket.on('close-lobby', async (data) => {
  const { lobbyId } = data;
  
  // Clean up configuration
  profanityFilterService.removeConfiguration(lobbyId);
});
```

## Testing

Run the test suite:
```bash
npm test
```

View coverage:
```bash
npm test -- --coverage
```

## Implementation Details

- **Caching**: Filter instances are cached based on configuration to improve performance
- **Memory Management**: Unused configurations can be removed when contexts (lobbies) close
- **Extensibility**: Easy to add new strictness levels or configuration options
- **Thread-Safe**: Singleton pattern ensures consistent state across the application

## Future Enhancements

Potential improvements for future versions:
- User-specific filter preferences
- Language-specific filters
- Machine learning-based content moderation
- Severity scoring for flagged content
- Admin interface for managing word lists
- Integration with external moderation services
