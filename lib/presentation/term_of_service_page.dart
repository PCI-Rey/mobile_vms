import 'package:flutter/material.dart';
import '../../presentation/dashboard.dart';

import '../core/core.dart';

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Pastikan ScrollController sudah attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _onScroll(); // Mengecek posisi awal scroll setelah build selesai
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    const double tolerance = 20.0; // supaya tidak terlalu sensitif

    final atBottom = currentScroll >= (maxScroll - tolerance);

    if (atBottom != _isAtBottom) {
      setState(() {
        _isAtBottom = atBottom;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: SingleChildScrollView(
              controller: _scrollController,

              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms of Service',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  SpaceHeight(4),
                  Text(
                    'Last updated july 12,2025',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SpaceHeight(24),

                  Text(style: TextStyles.subtitle1, 'Introduction'),
                  Text(
                    style: TextStyles.caption,
                    'Vulputate odio turpis mattis porttitor. Risus scelerisque sit sagittis urna. At sem est aenean scelerisque velit id odio urna. '
                    'Amet urna sociis sed tincidunt ut. Dui posuere mattis diam convallis nullam dictum. Morbi velit feugiat nibh viverra ornare aliquam libero. '
                    'Accumsan condimentum nulla donec vel tortor. Orci nisi commodo massa at. Lobortis etiam nulla diam cursus elit id consequat ut.',
                  ),
                  SpaceHeight(24),

                  Text(style: TextStyles.subtitle1, 'Service provider'),
                  Text(
                    style: TextStyles.caption,
                    'Nulla morbi auctor lorem tempus elementum rhoncus. Augue tortor habitant suspendisse ultricies ac feugiat amet cursus mattis.\n'
                    'Orci nisi commodo massa at. Lobortis etiam nulla diam cursus elit id consequat ut.\n'
                    'Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed qu.',
                  ),

                  SpaceHeight(24),
                  Text(style: TextStyles.subtitle1, 'Age requirements'),
                  Text(
                    style: TextStyles.caption,
                    'Sed egestas mauris lacus dignissim aenean vel. Imperdiet eu blandit gravida elementum hendrerit felis aliquet et hac. '
                    'Non mi fringilla duis in non. Mi eros a quam suspendisse. Nibh tortor tincidunt in nulla convallis hendrerit mauris eleifend.\n\n'
                    'Lectus eget sapien nisl egestas tincidunt nunc diam. Turpis vel ipsum vestibulum amet nibh. In nunc elementum accumsan interdum '
                    'eu commodo suspendisse. Viverra egestas nisl ac porttitor. Nullam pretium duis lacus at. Quis autem vel eum iure reprehenderit '
                    'qui in ea voluptate velit esse quam nihil molestiae consequatur.',
                  ),
                  SpaceHeight(24),
                  Text(style: TextStyles.subtitle1, 'Lorem ipsum'),
                  Text(
                    style: TextStyles.caption,
                    'Nulla morbi auctor lorem tempus elementum rhoncus. Augue tortor habitant suspendisse ultricies ac feugiat amet cursus mattis.\n\n'
                    'Lectus eget sapien nisl egestas tincidunt nunc diam. Turpis vel ipsum vestibulum amet nibh. In nunc elementum accumsan interdum '
                    'eu commodo suspendisse. Viverra egestas nisl ac porttitor. Nullam pretium duis lacus at. Quis autem vel eum iure reprehenderit '
                    'Nulla morbi auctor lorem tempus elementum rhoncus. Augue tortor habitant suspendisse ultricies ac feugiat amet cursus mattis.\n\n'
                    'Lectus eget sapien nisl egestas tincidunt nunc diam. Turpis vel ipsum vestibulum amet nibh. In nunc elementum accumsan interdum '
                    'eu commodo suspendisse. Viverra egestas nisl ac porttitor. Nullam pretium duis lacus at. Quis autem vel eum iure reprehenderit '
                    'Nulla morbi auctor lorem tempus elementum rhoncus. Augue tortor habitant suspendisse ultricies ac feugiat amet cursus mattis.\n\n'
                    'Lectus eget sapien nisl egestas tincidunt nunc diam. Turpis vel ipsum vestibulum amet nibh. In nunc elementum accumsan interdum '
                    'eu commodo suspendisse. Viverra egestas nisl ac porttitor. Nullam pretium duis lacus at. Quis autem vel eum iure reprehenderit '
                    'Nulla morbi auctor lorem tempus elementum rhoncus. Augue tortor habitant suspendisse ultricies ac feugiat amet cursus mattis.\n\n'
                    'Lectus eget sapien nisl egestas tincidunt nunc diam. Turpis vel ipsum vestibulum amet nibh. In nunc elementum accumsan interdum '
                    'eu commodo suspendisse. Viverra egestas nisl ac porttitor. Nullam pretium duis lacus at. Quis autem vel eum iure reprehenderit '
                    'Nulla morbi auctor lorem tempus elementum rhoncus. Augue tortor habitant suspendisse ultricies ac feugiat amet cursus mattis.\n\n'
                    'Lectus eget sapien nisl egestas tincidunt nunc diam. Turpis vel ipsum vestibulum amet nibh. In nunc elementum accumsan interdum '
                    'eu commodo suspendisse. Viverra egestas nisl ac porttitor. Nullam pretium duis lacus at. Quis autem vel eum iure reprehenderit '
                    'Nulla morbi auctor lorem tempus elementum rhoncus. Augue tortor habitant suspendisse ultricies ac feugiat amet cursus mattis.\n\n'
                    'Lectus eget sapien nisl egestas tincidunt nunc diam. Turpis vel ipsum vestibulum amet nibh. In nunc elementum accumsan interdum '
                    'eu commodo suspendisse. Viverra egestas nisl ac porttitor. Nullam pretium duis lacus at. Quis autem vel eum iure reprehenderit '
                    'qui in ea voluptate velit esse quam nihil molestiae consequatur.',
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                
                onPressed: _isAtBottom
                    ? () {
                        context.push(const Dashboard());
                      }
                    : null, // disable jika belum di bawah
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Accept Term & Condition',
                  style: TextStyles.subtitle1.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
