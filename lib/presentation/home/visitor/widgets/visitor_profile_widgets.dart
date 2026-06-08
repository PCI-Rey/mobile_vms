import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../../data/models/visitor_model.dart';

class VisitorProfileCard extends StatelessWidget {
  final InvitationVisitorModel visitor;
  final int index;
  final VoidCallback onTap;

  const VisitorProfileCard({
    super.key,
    required this.visitor,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: rw(context, 10),
              offset: Offset(0, rh(context, 3)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section: Index + Name
            Container(
              margin: EdgeInsets.fromLTRB(
                rw(context, 14),
                rh(context, 10),
                rw(context, 14),
                0,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 12),
                vertical: rh(context, 10),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF005596).withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(rw(context, 10)),
                border: Border.all(
                  color: const Color(0xFF005596).withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: rw(context, 26),
                    height: rw(context, 26),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF005596),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: rfs(context, 11),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  hSpace(context, 10),
                  Expanded(
                    child: Text(
                      visitor.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: rfs(context, 14),
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom section: Detail Grid
            Container(
              margin: EdgeInsets.fromLTRB(
                rw(context, 14),
                rh(context, 8),
                rw(context, 14),
                rh(context, 12),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 12),
                vertical: rh(context, 10),
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(rw(context, 10)),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          context,
                          Icons.business_outlined,
                          'Organization',
                          visitor.organization.isEmpty ? '-' : visitor.organization,
                        ),
                      ),
                      hSpace(context, 8),
                      Expanded(
                        child: _buildField(
                          context,
                          Icons.credit_card_outlined,
                          'Identity ID',
                          visitor.identityId.isEmpty ? '-' : visitor.identityId,
                        ),
                      ),
                    ],
                  ),
                  vSpace(context, 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          context,
                          Icons.phone_outlined,
                          'Phone',
                          visitor.phone.isEmpty ? '-' : visitor.phone,
                        ),
                      ),
                      hSpace(context, 8),
                      Expanded(
                        child: _buildField(
                          context,
                          Icons.email_outlined,
                          'Email',
                          visitor.email.isEmpty ? '-' : visitor.email,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, IconData icon, String label, String val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: rw(context, 16), color: Colors.grey[600]),
        hSpace(context, 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: rfs(context, 10),
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                val,
                style: TextStyle(
                  fontSize: rfs(context, 11),
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class VisitorProfileDetailSheet extends StatelessWidget {
  final InvitationVisitorModel visitor;

  const VisitorProfileDetailSheet({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(rw(context, 20)),
          topRight: Radius.circular(rw(context, 20)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: EdgeInsets.only(top: rh(context, 12)),
              child: Container(
                width: rw(context, 40),
                height: rh(context, 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(rw(context, 2)),
                ),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 20),
                vertical: rh(context, 14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(rw(context, 10)),
                    decoration: BoxDecoration(
                      color: const Color(0xFF005596).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(rw(context, 10)),
                    ),
                    child: const Icon(
                      Icons.person_pin_circle_outlined,
                      color: Color(0xFF005596),
                    ),
                  ),
                  hSpace(context, 12),
                  Expanded(
                    child: Text(
                      visitor.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: rfs(context, 16),
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: Colors.grey.shade100),

            // Body
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 20),
                vertical: rh(context, 16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _section(context, 'Visitor Information'),
                  _grid(context, [
                    _SheetField('Name', visitor.name.isEmpty ? '-' : visitor.name, Icons.person_outline),
                    _SheetField('Email', visitor.email.isEmpty ? '-' : visitor.email, Icons.email_outlined),
                    _SheetField('Phone', visitor.phone.isEmpty ? '-' : visitor.phone, Icons.phone_outlined),
                    _SheetField('Organization', visitor.organization.isEmpty ? '-' : visitor.organization, Icons.business_outlined),
                    _SheetField('Identity ID', visitor.identityId.isEmpty ? '-' : visitor.identityId, Icons.credit_card_outlined),
                    if (visitor.gender != null && visitor.gender!.isNotEmpty)
                      _SheetField('Gender', visitor.gender!, Icons.wc_outlined),
                  ]),
                ],
              ),
            ),
            vSpace(context, 8),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 12)),
      child: Row(
        children: [
          Container(
            width: rw(context, 4),
            height: rh(context, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF005596),
              borderRadius: BorderRadius.circular(rw(context, 2)),
            ),
          ),
          hSpace(context, 8),
          Text(
            title,
            style: TextStyle(
              fontSize: rfs(context, 14),
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(BuildContext context, List<_SheetField> fields) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(rw(context, 12)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 16),
        vertical: rh(context, 16),
      ),
      child: Column(
        children: List.generate(fields.length, (index) {
          final f = fields[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == fields.length - 1 ? 0 : rh(context, 14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: rh(context, 2)),
                  child: Icon(f.icon, size: rw(context, 16), color: Colors.grey[500]),
                ),
                hSpace(context, 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.label,
                        style: TextStyle(
                          fontSize: rfs(context, 10),
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      vSpace(context, 3),
                      Text(
                        f.value,
                        style: TextStyle(
                          fontSize: rfs(context, 13),
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SheetField {
  final String label;
  final String value;
  final IconData icon;

  _SheetField(this.label, this.value, this.icon);
}
