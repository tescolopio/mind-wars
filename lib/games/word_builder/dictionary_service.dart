/**
 * Word Builder Game - Dictionary Service
 * Word validation using a simple dictionary
 */

/// Dictionary service for word validation
class DictionaryService {
  // Simple word list for MVP (would be loaded from asset file in production)
  static final Set<String> _dictionary = {
    // 3-letter words
    'THE', 'AND', 'FOR', 'ARE', 'BUT', 'NOT', 'YOU', 'ALL', 'CAN', 'HER',
    'WAS', 'ONE', 'OUR', 'OUT', 'DAY', 'GET', 'HAS', 'HIM', 'HIS', 'HOW',
    'MAN', 'NEW', 'NOW', 'OLD', 'SEE', 'TWO', 'WAY', 'WHO', 'BOY', 'ITS',
    'LET', 'PUT', 'SAY', 'SHE', 'TOO', 'USE', 'CAT', 'DOG', 'RUN', 'SIT',
    'EAT', 'BAT', 'RAT', 'HAT', 'MAT', 'SAT', 'FAT', 'TAR', 'CAR', 'BAR',
    'JAR', 'WAR', 'FAR', 'PAN', 'TAN', 'VAN', 'FAN', 'RAN',
    'BAN', 'TEN', 'PEN', 'HEN', 'DEN', 'NET', 'SET', 'WET', 'PET', 'MET',
    'LET', 'BET', 'GET', 'JET', 'TEA', 'SEA', 'PEA', 'BEE', 'SEE', 'FEE',
    'ATE', 'APE', 'ACE', 'AGE', 'AXE', 'ARE', 'ICE', 'ORE', 'OWE', 'ODE',
    'ZEN', 'JAM', 'VOW', 'ZAX', 'QUA', 'ZUZ', 'QAT', 'JOY', 'ZOO', 'ZIP',
    
    // 4-letter words
    'THAT', 'WITH', 'HAVE', 'THIS', 'WILL', 'YOUR', 'FROM', 'THEY', 'BEEN',
    'HAVE', 'WERE', 'SAID', 'EACH', 'SOME', 'TIME', 'VERY', 'WHEN', 'COME',
    'HERE', 'JUST', 'LIKE', 'LONG', 'MAKE', 'MANY', 'OVER', 'SUCH', 'TAKE',
    'THAN', 'THEM', 'WELL', 'ONLY', 'BACK', 'ALSO', 'INTO', 'THEN', 'MOST',
    'CATS', 'DOGS', 'RUNS', 'SITS', 'EATS', 'BATS', 'RATS', 'HATS', 'MATS',
    'TARS', 'CARS', 'BARS', 'JARS', 'WARS', 'PANS', 'TANS', 'VANS', 'FANS',
    'TENS', 'PENS', 'HENS', 'NETS', 'SETS', 'PETS', 'TEAS', 'SEAS', 'PEAS',
    'BEES', 'FEES', 'APES', 'ACES', 'AGES', 'AXES', 'ICES', 'ORES', 'OWES',
    'WORD', 'NEST', 'REST', 'TEST', 'BEST', 'WEST', 'EAST', 'FAST', 'LAST',
    'PAST', 'CAST', 'MAST', 'VAST', 'LIST', 'MIST', 'FIST', 'GIST', 'RUST',
    
    // 5-letter words
    'ABOUT', 'WOULD', 'THERE', 'THEIR', 'WHICH', 'COULD', 'OTHER', 'THESE',
    'FIRST', 'WATER', 'AFTER', 'WHERE', 'UNDER', 'THINK', 'STILL', 'GREAT',
    'EVERY', 'FOUND', 'WORLD', 'THREE', 'STATE', 'NEVER', 'SMALL', 'HOUSE',
    'THOSE', 'PLACE', 'ASKED', 'GOING', 'POINT', 'LATER', 'THING', 'RIGHT',
    'WORDS', 'NESTS', 'RESTS', 'TESTS', 'BESTS', 'WESTS', 'EASTS', 'FASTS',
    'LASTS', 'PASTS', 'CASTS', 'MASTS', 'VASTS', 'LISTS', 'MISTS', 'FISTS',
    'STEAM', 'STARE', 'STORE', 'STONE', 'STOVE', 'STERN', 'STEAL', 'STEEL',
    'TALES', 'TAKES', 'TAPES', 'RATES', 'GATES', 'DATES', 'HATES', 'MATES',
    
    // 6-letter words
    'BEFORE', 'SHOULD', 'DURING', 'BECOME', 'LITTLE', 'ALWAYS', 'CALLED',
    'PEOPLE', 'AROUND', 'SCHOOL', 'NUMBER', 'MOTHER', 'FATHER', 'CHANGE',
    'RETURN', 'STREAM', 'STORES', 'STONES', 'STOVES', 'STERNS', 'STEALS',
    'STEELS', 'TALLER', 'FASTER', 'SLOWER', 'CLOSER', 'TABLES', 'CABLES',
    
    // 7+ letter words
    'THROUGH', 'ANOTHER', 'WITHOUT', 'BETWEEN', 'NOTHING', 'BECAUSE',
    'AGAINST', 'HOWEVER', 'SEVERAL', 'PRESENT', 'STARTED', 'RUNNING',
    'SITTING', 'EATING', 'TESTING', 'RESTING', 'STEAMER', 'STREAMS',
    'DISABLE', 'MISREAD', 'PRETEST', 'UNTESTED', 'LONGEST', 'FASTEST',
    'TEACHERS', 'STUDENTS', 'LEARNING', 'TEACHING',
  };

  /// Check if a word is valid
  bool isValidWord(String word) {
    return _dictionary.contains(word.toUpperCase());
  }

  /// Get word frequency bucket (1-5, where 1 is most common)
  /// Returns null if word not in dictionary
  int? getFrequencyBucket(String word) {
    if (!isValidWord(word)) return null;

    final upperWord = word.toUpperCase();
    
    // Simple heuristic based on word length and commonality
    // In production, this would use actual frequency data
    if (upperWord.length == 3) {
      if (_commonWords.contains(upperWord)) return 1;
      return 2;
    } else if (upperWord.length == 4) {
      return 2;
    } else if (upperWord.length == 5) {
      return 3;
    } else if (upperWord.length == 6) {
      return 4;
    } else {
      return 5; // 7+ letters are rare
    }
  }

  // Common 3-letter words
  static const Set<String> _commonWords = {
    'THE', 'AND', 'FOR', 'ARE', 'BUT', 'NOT', 'YOU', 'ALL', 'CAN', 'HER',
    'WAS', 'ONE', 'OUR', 'OUT', 'DAY', 'GET', 'HAS', 'HIM', 'HIS', 'HOW',
  };

  /// Get dictionary size
  int get dictionarySize => _dictionary.length;

  /// Check if dictionary is loaded
  bool get isLoaded => _dictionary.isNotEmpty;
}
