import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';
import 'quiz_result_page.dart';

class TravelQuizPage extends StatefulWidget {
  const TravelQuizPage({super.key});

  @override
  State<TravelQuizPage> createState() => _TravelQuizPageState();
}

class _TravelQuizPageState extends State<TravelQuizPage> {
  final List<QuizQuestion> _questions = QuizData.getQuizQuestions();
  int _currentQuestionIndex = 0;
  List<List<int>> _answers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnswers();
  }

  // 初始化答案列表
  void _initializeAnswers() {
    _answers = List.generate(
      _questions.length, 
      (index) => _questions[index].multiSelect ? [] : [-1],
    );
  }

  // 進度百分比
  double get _progress {
    return (_currentQuestionIndex + 1) / _questions.length;
  }

  // 是否為當前問題的最後一個選項
  bool get _isLastQuestion {
    return _currentQuestionIndex == _questions.length - 1;
  }

  // 判斷當前問題是否已回答
  bool _isCurrentQuestionAnswered() {
    final answer = _answers[_currentQuestionIndex];
    if (_questions[_currentQuestionIndex].multiSelect) {
      return answer.isNotEmpty;
    } else {
      return answer[0] != -1;
    }
  }

  // 處理選項選擇
  void _handleOptionSelected(int optionIndex) {
    setState(() {
      if (_questions[_currentQuestionIndex].multiSelect) {
        // 多選題
        final maxSelections = _questions[_currentQuestionIndex].maxSelections;
        final currentAnswers = _answers[_currentQuestionIndex];
        
        if (currentAnswers.contains(optionIndex)) {
          // 如果已經選擇，取消選擇
          currentAnswers.remove(optionIndex);
        } else {
          // 如果未選擇且未達到最大選擇數，添加選擇
          if (currentAnswers.length < maxSelections) {
            currentAnswers.add(optionIndex);
          } else {
            // 如果已達到最大選擇數，顯示提示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('最多選擇$maxSelections項')),
            );
          }
        }
      } else {
        // 單選題
        _answers[_currentQuestionIndex] = [optionIndex];
      }
    });
  }

  // 處理下一題
  void _handleNextQuestion() {
    if (_isLastQuestion) {
      // 如果是最後一題，提交測驗
      _submitQuiz();
    } else {
      // 否則跳到下一題
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  // 處理上一題
  void _handlePreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  // 提交測驗
  Future<void> _submitQuiz() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 計算測驗結果
      final result = QuizService.calculateQuizResult(_answers);
        // 更新用戶的旅遊類型
      await QuizService.updateTravelType(_answers);
      
      if (mounted) {
        // 導航到結果頁面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultPage(
              result: result,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交測驗失敗：$e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('旅遊類型測驗'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // 進度條
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '問題 ${_currentQuestionIndex + 1}/${_questions.length}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 問題和選項
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 問題
                          Text(
                            currentQuestion.question,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (currentQuestion.multiSelect)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '請選擇最多${currentQuestion.maxSelections}項',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          
                          // 選項
                          ...List.generate(
                            currentQuestion.options.length,
                            (index) {
                              final isSelected = currentQuestion.multiSelect
                                  ? _answers[_currentQuestionIndex].contains(index)
                                  : _answers[_currentQuestionIndex][0] == index;
                              
                              return _buildOptionCard(
                                option: currentQuestion.options[index],
                                isSelected: isSelected,
                                onTap: () => _handleOptionSelected(index),
                                isMultiSelect: currentQuestion.multiSelect,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 導航按鈕
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // 上一題
                        if (_currentQuestionIndex > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _handlePreviousQuestion,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                foregroundColor: Colors.purple,
                                side: const BorderSide(color: Colors.purple),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('上一題'),
                            ),
                          ),
                        if (_currentQuestionIndex > 0)
                          const SizedBox(width: 16),
                        
                        // 下一題/提交
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isCurrentQuestionAnswered()
                                ? _handleNextQuestion
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(_isLastQuestion ? '提交' : '下一題'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // 構建選項卡片
  Widget _buildOptionCard({
    required String option,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isMultiSelect,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.purple : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 複選框或單選框
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: isMultiSelect ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: isMultiSelect ? BorderRadius.circular(4) : null,
                  border: Border.all(
                    color: isSelected ? Colors.purple : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: isSelected ? Colors.purple : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        isMultiSelect ? Icons.check : Icons.circle,
                        size: isMultiSelect ? 18 : 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // 選項文字
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.purple : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
