import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(Portfolio());
}

class Portfolio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anuja Mishra - Flutter Developer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: FutureBuilder<Map<String, dynamic>>(
        future: _loadPortfolioData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final data = snapshot.data ?? {};
          return PortfolioHomePage(data: data);
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<Map<String, dynamic>> _loadPortfolioData() async {
  try {
    final jsonString = await rootBundle.loadString('assets/data/portfolio.json');
    final Map<String, dynamic> decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return decoded;
  } catch (_) {
    return {};
  }
}

class PortfolioHomePage extends StatefulWidget {
  final Map<String, dynamic> data;

  PortfolioHomePage({required this.data});
  @override
  _PortfolioHomePageState createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  bool _showProfileStrip = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _scrollController.addListener(_onScrollChanged);
  }

  void _onScrollChanged() {
    final bool shouldShow = _scrollController.hasClients && _scrollController.offset > 40;
    if (shouldShow != _showProfileStrip) {
      setState(() {
        _showProfileStrip = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.data['profile'] as Map<String, dynamic>?;
    final about = widget.data['about'] as Map<String, dynamic>?;
    final skillsData = (widget.data['skills'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final experiences = (widget.data['experience'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final projects = (widget.data['projects'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Container(key: _heroKey, child: HeroSection(profile: profile)),
              Container(key: _aboutKey, child: AboutSection(about: about)),
              Container(key: _skillsKey, child: SkillsSection.fromData(skillsData)),
              Container(key: _experienceKey, child: ExperienceSection.fromData(experiences)),
              Container(key: _projectsKey, child: ProjectsSection.fromData(projects)),
              Container(key: _contactKey, child: ContactSection(profile: profile)),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final String topTitleText = 'Portfolio';
    final profile = widget.data['profile'] as Map<String, dynamic>?;
    final String profileName = (profile?['name'] as String?) ?? 'Anuja Mishra';
    final String? profileImage = profile?['profileImage'] as String?;
    final double width = MediaQuery.of(context).size.width;
    final bool compact = width < 900;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4,
      title: Text(
        topTitleText,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.w700),
      ),
      centerTitle: false,
      actions: compact
          ? [
              PopupMenuButton<String>(
                icon: Icon(Icons.menu, color: Color(0xFF2D3748)),
                onSelected: (value) {
                  switch (value) {
                    case 'Home':
                      _scrollTo(_heroKey);
                      break;
                    case 'About':
                      _scrollTo(_aboutKey);
                      break;
                    case 'Skills':
                      _scrollTo(_skillsKey);
                      break;
                    case 'Experience':
                      _scrollTo(_experienceKey);
                      break;
                    case 'Projects':
                      _scrollTo(_projectsKey);
                      break;
                    case 'Contact':
                      _scrollTo(_contactKey);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'Home', child: Text('Home')),
                  PopupMenuItem(value: 'About', child: Text('About')),
                  PopupMenuItem(value: 'Skills', child: Text('Skills')),
                  PopupMenuItem(value: 'Experience', child: Text('Experience')),
                  PopupMenuItem(value: 'Projects', child: Text('Projects')),
                  PopupMenuItem(value: 'Contact', child: Text('Contact')),
                ],
              ),
              SizedBox(width: 8),
            ]
          : [
              _navButton('Home', _heroKey),
              _navButton('About', _aboutKey),
              _navButton('Skills', _skillsKey),
              _navButton('Experience', _experienceKey),
              _navButton('Projects', _projectsKey),
              _navButton('Contact', _contactKey),
              SizedBox(width: 12),
            ],
      bottom: _showProfileStrip
          ? PreferredSize(
              preferredSize: Size.fromHeight(72),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: profileImage != null
                            ? Image.asset(
                                profileImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.person, color: Color(0xFF2D3748));
                                },
                              )
                            : Icon(Icons.person, color: Color(0xFF2D3748)),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      profileName,
                      style: TextStyle(
                        color: Color(0xFF2D3748),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _navButton(String label, GlobalKey key) {
    return TextButton(
      onPressed: () => _scrollTo(key),
      child: Text(label, style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.w600)),
    );
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }
}

class HeroSection extends StatelessWidget {
  final Map<String, dynamic>? profile;

  HeroSection({this.profile});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
            Color(0xFF6B73FF),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade200],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    (profile?['profileImage'] as String?) ?? 'assets/images/profile.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.grey.shade600,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text(
                (profile?['name'] as String?) ?? 'ANUJA MISHRA',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  (profile?['role'] as String?) ?? 'Flutter Developer',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                ((profile?['tagline'] as String?) ?? 'Crafting exceptional mobile experiences with modern Flutter development'),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    'Get In Touch',
                    Icons.mail_outline,
                        () => _launchURL((profile?['links']?['email'] as String?) ?? 'mailto:anujamishra0808@gmail.com'),
                    isPrimary: true,
                  ),
                  SizedBox(width: 20),
                  _buildActionButton(
                    'View Projects',
                    Icons.work_outline,
                        () => _launchURL((profile?['links']?['github'] as String?) ?? 'https://github.com/anuja08-07'),
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed, {required bool isPrimary}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.white : Colors.transparent,
        foregroundColor: isPrimary ? Color(0xFF667eea) : Colors.white,
        side: isPrimary ? null : BorderSide(color: Colors.white, width: 2),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: isPrimary ? 8 : 0,
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class AboutSection extends StatelessWidget {
  final Map<String, dynamic>? about;
  AboutSection({this.about});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      color: Color(0xFFFAFAFA),
      child: Column(
        children: [
          Text(
            (about?['title'] as String?) ?? 'About Me',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFF667eea),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 50),
          Container(
            constraints: BoxConstraints(maxWidth: 800),
            child: Column(
              children: ((about?['paragraphs'] as List?) ?? [
                'Passionate Flutter Developer with 6+ months of hands-on experience building high-quality, cross-platform mobile applications. I specialize in creating intuitive user interfaces and implementing robust architectures.',
                'My expertise encompasses the complete mobile development lifecycle, from UI/UX design to deployment, with a strong focus on performance optimization, clean code practices, and modern development patterns.',
              ]).map<Widget>((p) => Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  p.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.7,
                    color: Color(0xFF4A5568),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class SkillsSection extends StatelessWidget {
  final List<Skill> skills;
  SkillsSection({required this.skills});
  factory SkillsSection.fromData(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return SkillsSection(skills: [
        Skill('Flutter', 0.95, Color(0xFF02569B)),
        Skill('Dart', 0.90, Color(0xFF0175C2)),
        Skill('Firebase', 0.85, Color(0xFFFFCA28)),
        Skill('State Management', 0.88, Color(0xFF9C27B0)),
        Skill('API Integration', 0.85, Color(0xFF4CAF50)),
        Skill('UI/UX Design', 0.80, Color(0xFFE91E63)),
        Skill('Git & Version Control', 0.85, Color(0xFFFF5722)),
        Skill('Testing', 0.75, Color(0xFF607D8B)),
      ]);
    }
    return SkillsSection(
      skills: data.map((e) => Skill(
        e['name'] as String,
        (e['level'] as num).toDouble(),
        _parseHexColor(e['color'] as String),
      )).toList(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Technical Skills',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFF667eea),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 80),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.5,
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
            ),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              return SkillCard(skill: skills[index]);
            },
          ),
        ],
      ),
    );
  }
}

class Skill {
  final String name;
  final double level;
  final Color color;

  Skill(this.name, this.level, this.color);
}

class SkillCard extends StatefulWidget {
  final Skill skill;

  SkillCard({required this.skill});

  @override
  _SkillCardState createState() => _SkillCardState();
}

class _SkillCardState extends State<SkillCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.skill.level).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: 300), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.skill.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                '${(widget.skill.level * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.skill.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _animation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.skill.color,
                          widget.skill.color.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExperienceSection extends StatelessWidget {
  final List<Map<String, dynamic>> experiences;
  ExperienceSection({required this.experiences});
  factory ExperienceSection.fromData(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return ExperienceSection(experiences: [
        {
          'company': 'Brainwave Labs Pvt. Ltd',
          'position': 'Flutter Developer',
          'duration': 'July 2024 – January 2025',
          'color': '#667eea',
          'description': [
            'Developed Buddy Learning educational app with interactive modules and video streaming',
            'Improved app performance by 35% through code optimization and best practices',
            'Implemented complex UI components with custom animations and transitions',
            'Integrated RESTful APIs and managed state using GetX and Provider patterns',
            'Collaborated with design and backend teams in agile development environment',
          ],
        },
        {
          'company': 'Electronics Corporation of India Limited (ECIL)',
          'position': 'Technical Trainee',
          'duration': 'May 2023 – July 2023',
          'color': '#38B2AC',
          'description': [
            'Developed CSTM GUI application using FastAPI and SQLite database',
            'Created comprehensive test suites achieving 85% code coverage',
            'Optimized application performance resulting in 40% faster response times',
            'Collaborated with senior developers on system architecture decisions',
            'Applied modern software development practices and version control',
          ],
        },
      ]);
    }
    return ExperienceSection(experiences: data);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      color: Color(0xFFFAFAFA),
      child: Column(
        children: [
          Text(
            'Professional Experience',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFF667eea),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 80),
          ...experiences.map((e) => Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: ExperienceCard(
              company: e['company'] as String,
              position: e['position'] as String,
              duration: e['duration'] as String,
              description: (e['description'] as List).cast<String>(),
              color: _parseHexColor(e['color'] as String),
            ),
          )),
        ],
      ),
    );
  }
}

class ExperienceCard extends StatelessWidget {
  final String company;
  final String position;
  final String duration;
  final List<String> description;
  final Color color;

  ExperienceCard({
    required this.company,
    required this.position,
    required this.duration,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 25,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      position,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      company,
                      style: TextStyle(
                        fontSize: 18,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF718096),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          ...description.map((desc) => Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 8, right: 12),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    desc,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A5568),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class ProjectsSection extends StatelessWidget {
  final List<ProjectModel> projects;
  ProjectsSection({required this.projects});
  factory ProjectsSection.fromData(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return ProjectsSection(projects: [
        ProjectModel(
          title: 'Buddy Learning Educational App',
          description: 'Cross-platform educational app with interactive learning modules, video streaming, and progress tracking for enhanced student engagement.',
          technologies: ['Flutter', 'Dart', 'GetX', 'Python Backend', 'Video Streaming'],
          githubUrl: 'https://github.com/anuja08-07',
          features: [
            'Interactive learning modules',
            'Video streaming integration',
            'Student progress tracking',
            'Offline content access',
            'Real-time notifications',
          ],
          imagePath: 'assets/images/buddy_learning.png',
          gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        ProjectModel(
          title: 'Voice-Controlled News App',
          description: 'Accessible news application with voice command functionality and real-time data integration for hands-free news consumption.',
          technologies: ['React.js', 'Alan AI', 'News API', 'Responsive Design', 'PWA'],
          githubUrl: 'https://github.com/anuja08-07',
          features: [
            'Voice command interface',
            'Real-time news updates',
            'Accessible design',
            'Category-based filtering',
            'Progressive Web App',
          ],
          imagePath: 'assets/images/voice_news.png',
          gradient: [Color(0xFF74b9ff), Color(0xFF0984e3)],
        ),
        ProjectModel(
          title: 'Remote Sensing Analysis',
          description: 'Deep learning model for object detection in remote sensing images with high accuracy using advanced CNN architecture.',
          technologies: ['Python', 'Keras', 'OpenCV', 'Matplotlib', 'TensorFlow'],
          githubUrl: 'https://github.com/anuja08-07',
          features: [
            'CNN model with 85% accuracy',
            'Image preprocessing pipeline',
            'Feature engineering',
            'Performance optimization',
            'Batch processing support',
          ],
          imagePath: 'assets/images/remote_sensing.png',
          gradient: [Color(0xFF56ab2f), Color(0xFFa8e6cf)],
        ),
      ]);
    }
    return ProjectsSection(
      projects: data.map((e) => ProjectModel(
        title: e['title'] as String,
        description: e['description'] as String,
        technologies: (e['technologies'] as List).cast<String>(),
        githubUrl: e['githubUrl'] as String,
        features: (e['features'] as List).cast<String>(),
        imagePath: e['imagePath'] as String,
        gradient: (e['gradient'] as List).map<Color>((c) => _parseHexColor(c as String)).toList(),
      )).toList(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Featured Projects',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFF667eea),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 80),
          ...projects.map((project) => Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: ProjectCard(project: project),
          )),
        ],
      ),
    );
  }
}

class ProjectModel {
  final String title;
  final String description;
  final List<String> technologies;
  final String githubUrl;
  final List<String> features;
  final String imagePath;
  final List<Color> gradient;

  ProjectModel({
    required this.title,
    required this.description,
    required this.technologies,
    required this.githubUrl,
    required this.features,
    required this.imagePath,
    required this.gradient,
  });
}

class ProjectCard extends StatelessWidget {
  final ProjectModel project;

  ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: project.gradient,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    project.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to a default icon if image not found
                      return Icon(
                        Icons.flutter_dash,
                        size: 80,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  project.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4A5568),
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Key Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 16),
                ...project.features.map((feature) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: project.gradient[0],
                        size: 18,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: project.technologies
                      .map((tech) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          project.gradient[0].withOpacity(0.1),
                          project.gradient[1].withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: project.gradient[0].withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      tech,
                      style: TextStyle(
                        color: project.gradient[0],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
                      .toList(),
                ),
                SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _launchURL(project.githubUrl),
                  icon: Icon(Icons.code, size: 18),
                  label: Text('View Source Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2D3748),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class ContactSection extends StatelessWidget {
  final Map<String, dynamic>? profile;
  ContactSection({this.profile});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D3748),
            Color(0xFF1A202C),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Let\'s Work Together',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFF667eea),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 30),
          Text(
            'Ready to bring your mobile app ideas to life?\nLet\'s discuss your next project.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              ContactButton(
                icon: Icons.email_outlined,
                label: 'Email',
                onPressed: () => _launchURL((profile?['links']?['email'] as String?) ?? 'mailto:anujamishra0808@gmail.com'),
              ),
              ContactButton(
                icon: Icons.phone_outlined,
                label: 'Call',
                onPressed: () => _launchURL((profile?['links']?['phone'] as String?) ?? 'tel:+916301479708'),
              ),
              ContactButton(
                icon: Icons.work_outline,
                label: 'LinkedIn',
                onPressed: () => _launchURL((profile?['links']?['linkedin'] as String?) ?? 'https://linkedin.com/in/anujamishra0807'),
              ),
              ContactButton(
                icon: Icons.code,
                label: 'GitHub',
                onPressed: () => _launchURL((profile?['links']?['github'] as String?) ?? 'https://github.com/anuja08-07'),
              ),
            ],
          ),
          SizedBox(height: 80),
          Text(
            '© 2024 Anuja Mishra. Built with Flutter 💙',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  ContactButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2D3748),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

Color _parseHexColor(String hex) {
  String cleaned = hex.replaceAll('#', '').toUpperCase();
  if (cleaned.length == 6) cleaned = 'FF$cleaned';
  final intVal = int.parse(cleaned, radix: 16);
  return Color(intVal);
}