/**
 * Unit tests for Scorer
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/games/word_builder/scorer.dart';

void main() {
  group('Scorer', () {
    late Scorer scorer;

    setUp(() {
      scorer = Scorer();
    });

    group('Base Score Calculation', () {
      test('should calculate base score as length squared', () {
        final breakdown = scorer.calculateScore('CAT', false, false, {'C', 'A', 'T'});
        
        expect(breakdown.baseScore, equals(9)); // 3² = 9
      });

      test('should calculate different base scores for different lengths', () {
        final breakdown4 = scorer.calculateScore('CATS', false, false, {'C', 'A', 'T', 'S'});
        final breakdown5 = scorer.calculateScore('TIGER', false, false, {'T', 'I', 'G', 'E', 'R'});
        
        expect(breakdown4.baseScore, equals(16)); // 4² = 16
        expect(breakdown5.baseScore, equals(25)); // 5² = 25
      });
    });

    group('Rarity Bonus', () {
      test('should give 0 bonus for common words', () {
        final breakdown = scorer.calculateScore('THE', false, false, {'T', 'H', 'E'});
        
        expect(breakdown.rarityBonus, equals(0));
      });

      test('should give bonus for uncommon words', () {
        final breakdown = scorer.calculateScore('CAT', false, false, {'C', 'A', 'T'});
        
        expect(breakdown.rarityBonus, greaterThan(0));
      });

      test('should give higher bonus for rare words', () {
        final breakdown = scorer.calculateScore('ZEN', false, false, {'Z', 'E', 'N'});
        
        expect(breakdown.rarityBonus, greaterThanOrEqualTo(10));
      });
    });

    group('Pattern Bonus', () {
      test('should give bonus for words with prefixes', () {
        final breakdown = scorer.calculateScore('UNTESTED', false, false, 
            {'U', 'N', 'T', 'E', 'S', 'D'});
        
        expect(breakdown.patternBonus, equals(5));
      });

      test('should give bonus for words with suffixes', () {
        final breakdown = scorer.calculateScore('RUNNING', false, false, 
            {'R', 'U', 'N', 'I', 'G'});
        
        expect(breakdown.patternBonus, equals(5));
      });

      test('should give bonus for long compound-style words', () {
        final breakdown = scorer.calculateScore('TEACHERS', false, false, 
            {'T', 'E', 'A', 'C', 'H', 'R', 'S'});
        
        expect(breakdown.patternBonus, equals(5));
      });

      test('should not give pattern bonus for short words', () {
        final breakdown = scorer.calculateScore('CAT', false, false, {'C', 'A', 'T'});
        
        expect(breakdown.patternBonus, equals(0));
      });
    });

    group('Pangram Bonus', () {
      test('should give pangram bonus when isPangram is true', () {
        final breakdown = scorer.calculateScore('ABCDEFGHI', true, false, 
            {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'});
        
        expect(breakdown.pangramBonus, equals(50));
      });

      test('should not give pangram bonus when isPangram is false', () {
        final breakdown = scorer.calculateScore('CAT', false, false, {'C', 'A', 'T'});
        
        expect(breakdown.pangramBonus, equals(0));
      });
    });

    group('Multipliers', () {
      test('should apply golden tile multiplier', () {
        final breakdown = scorer.calculateScore('CAT', false, true, {'C', 'A', 'T'});
        
        expect(breakdown.multiplier, equals(2.0));
        expect(breakdown.finalScore, greaterThan(breakdown.baseScore + breakdown.rarityBonus));
      });

      test('should apply pangram multiplier', () {
        final breakdown = scorer.calculateScore('ABCDEFGHI', true, false, 
            {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'});
        
        expect(breakdown.multiplier, equals(2.0));
      });

      test('should stack golden and pangram multipliers', () {
        final breakdown = scorer.calculateScore('ABCDEFGHI', true, true, 
            {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'});
        
        expect(breakdown.multiplier, equals(4.0)); // 2.0 * 2.0
      });

      test('should have no multiplier by default', () {
        final breakdown = scorer.calculateScore('CAT', false, false, {'C', 'A', 'T'});
        
        expect(breakdown.multiplier, equals(1.0));
      });
    });

    group('Final Score Calculation', () {
      test('should calculate final score correctly', () {
        final breakdown = scorer.calculateScore('CAT', false, false, {'C', 'A', 'T'});
        
        final expectedScore = breakdown.baseScore + 
                             breakdown.rarityBonus + 
                             breakdown.patternBonus + 
                             breakdown.pangramBonus;
        
        expect(breakdown.finalScore, equals(expectedScore));
      });

      test('should apply multiplier to final score', () {
        final breakdown = scorer.calculateScore('CAT', false, true, {'C', 'A', 'T'});
        
        final subtotal = breakdown.baseScore + 
                        breakdown.rarityBonus + 
                        breakdown.patternBonus + 
                        breakdown.pangramBonus;
        final expected = (subtotal * 2.0).round();
        
        expect(breakdown.finalScore, equals(expected));
      });
    });

    group('Efficiency Multiplier', () {
      test('should return 1.5 for exceeding target and 80%+ of max', () {
        final multiplier = scorer.calculateEfficiencyMultiplier(10, 10, 12);
        expect(multiplier, equals(1.5));
      });

      test('should return 1.2 for meeting target', () {
        final multiplier = scorer.calculateEfficiencyMultiplier(10, 10, 20);
        expect(multiplier, equals(1.2));
      });

      test('should return 1.2 for 60%+ of max', () {
        final multiplier = scorer.calculateEfficiencyMultiplier(7, 10, 10);
        expect(multiplier, equals(1.2));
      });

      test('should return 1.0 for below threshold', () {
        final multiplier = scorer.calculateEfficiencyMultiplier(5, 10, 20);
        expect(multiplier, equals(1.0));
      });

      test('should handle zero max gracefully', () {
        final multiplier = scorer.calculateEfficiencyMultiplier(5, 10, 0);
        expect(multiplier, equals(1.0));
      });
    });

    group('Player Percent Calculation', () {
      test('should calculate correct percentage', () {
        final percent = scorer.calculatePlayerPercent(75, 100);
        expect(percent, equals(75.0));
      });

      test('should handle 100% completion', () {
        final percent = scorer.calculatePlayerPercent(100, 100);
        expect(percent, equals(100.0));
      });

      test('should handle over-achievement', () {
        final percent = scorer.calculatePlayerPercent(120, 100);
        expect(percent, equals(120.0));
      });

      test('should handle zero max gracefully', () {
        final percent = scorer.calculatePlayerPercent(50, 0);
        expect(percent, equals(0.0));
      });
    });
  });
}
