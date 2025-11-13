/**
 * Sudoku Duel Game Widget - Alpha Implementation
 * Simple number placement puzzle
 * 
 * Category: Logic
 * Players: 2-4
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class SudokuDuelGame extends BaseGameWidget {
  const SudokuDuelGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<SudokuDuelGame> createState() => _SudokuDuelGameState();
}

class _SudokuDuelGameState extends BaseGameState<SudokuDuelGame> {
  late List<List<int>> _board;
  late List<List<bool>> _editable;
  int? _selectedRow;
  int? _selectedCol;
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _generateBoard();
  }

  void _generateBoard() {
    // Simplified 4x4 Sudoku for alpha
    _board = [
      [1, 2, 3, 4],
      [3, 4, 1, 2],
      [2, 1, 4, 3],
      [4, 3, 2, 1],
    ];
    
    _editable = List.generate(4, (_) => List.filled(4, false));
    
    // Remove some numbers
    final random = Random();
    for (var i = 0; i < 6; i++) {
      final row = random.nextInt(4);
      final col = random.nextInt(4);
      _editable[row][col] = true;
      _board[row][col] = 0;
    }
    
    setState(() {});
  }

  void _selectCell(int row, int col) {
    if (_editable[row][col]) {
      setState(() {
        _selectedRow = row;
        _selectedCol = col;
      });
    }
  }

  void _enterNumber(int number) {
    if (_selectedRow != null && _selectedCol != null) {
      setState(() {
        _board[_selectedRow!][_selectedCol!] = number;
      });
      
      if (_isComplete() && _isValid()) {
        addScore(50);
        showMessage('Sudoku solved! +50 points', success: true);
        _level++;
        
        if (_level > 3) {
          completeGame();
        } else {
          _generateBoard();
        }
      }
    }
  }

  bool _isComplete() {
    for (var row in _board) {
      for (var cell in row) {
        if (cell == 0) return false;
      }
    }
    return true;
  }

  bool _isValid() {
    // Check rows
    for (var row in _board) {
      final seen = <int>{};
      for (var cell in row) {
        if (cell != 0 && !seen.add(cell)) return false;
      }
    }
    
    // Check columns
    for (var col = 0; col < 4; col++) {
      final seen = <int>{};
      for (var row = 0; row < 4; row++) {
        final cell = _board[row][col];
        if (cell != 0 && !seen.add(cell)) return false;
      }
    }
    
    return true;
  }

  @override
  Widget buildGame(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Level $_level',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                final row = index ~/ 4;
                final col = index % 4;
                final value = _board[row][col];
                final isEditable = _editable[row][col];
                final isSelected = row == _selectedRow && col == _selectedCol;
                
                return GestureDetector(
                  onTap: () => _selectCell(row, col),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue[200]
                          : isEditable
                              ? Colors.white
                              : Colors.grey[300],
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        value == 0 ? '' : value.toString(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isEditable ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1, 2, 3, 4].map((num) {
              return ElevatedButton(
                onPressed: () => _enterNumber(num),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(60, 60),
                ),
                child: Text(
                  num.toString(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
