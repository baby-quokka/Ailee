import 'package:flutter/material.dart';

class WorkflowCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final List<Color> gradient;
  const WorkflowCard({Key? key, required this.post, required this.gradient})
    : super(key: key);

  @override
  State<WorkflowCard> createState() => _WorkflowCardState();
}

class _WorkflowCardState extends State<WorkflowCard>
    with SingleTickerProviderStateMixin {
  bool _opened = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleOpen() {
    setState(() {
      _opened = !_opened;
      if (_opened) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 0),
                    Row(
                      children: [
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.18),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: const BorderSide(color: Colors.white24),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _toggleOpen,
                          child: Text(_opened ? 'Close' : 'Open'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1.0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    post['content'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.6,
                    ),
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
