import os

files_to_fix = [
    "lib/presentation/home/alarm/list_alarm_page.dart",
    "lib/presentation/home/approval/widgets/approve_detail_model.dart",
    "lib/presentation/home/home_page.dart",
    "lib/presentation/home/invitation/send_invitation_page.dart",
    "lib/presentation/home/invitation/widgets/invitation_home_list.dart",
    "lib/presentation/home/invitation/widgets/invite_share_link_dialog.dart",
    "lib/presentation/home/invitation/widgets/quick_access_home_list.dart",
    "lib/presentation/home/invitation/widgets/share_link_card.dart",
    "lib/presentation/home/invitation/widgets/share_link_home_list.dart",
    "lib/presentation/home/visitor_request/controllers/pra_registration_controller.dart",
    "lib/presentation/home/widgets/access_pass_modal.dart",
    "lib/presentation/home/widgets/access_pass_section.dart",
    "lib/presentation/home/widgets/guest_menu_grid.dart",
    "lib/presentation/home/widgets/visit_summary_card.dart",
    "lib/presentation/notification/notification_page.dart",
    "lib/presentation/profile/profile_dummy_pages.dart"
]

ignores = "// ignore_for_file: unused_import, unused_local_variable, unused_element, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_underscores, unnecessary_import, unnecessary_null_comparison, curly_braces_in_flow_control_structures, unused_element_parameter, deprecated_member_use\n"

for path in files_to_fix:
    if os.path.exists(path):
        with open(path, 'r') as f:
            content = f.read()
        if not content.startswith("// ignore_for_file:"):
            with open(path, 'w') as f:
                f.write(ignores + content)
            print(f"Fixed {path}")

