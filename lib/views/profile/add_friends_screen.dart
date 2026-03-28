import 'package:flutter/material.dart';
import 'package:zplit/core/constants/colors.dart';

class Contact {
  final String name;
  final String avatarUrl; 
  bool isSelected;

  Contact({required this.name, required this.avatarUrl, this.isSelected = false});
}

class AddFriendsScreen extends StatefulWidget {
  const AddFriendsScreen({super.key});

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  final List<Contact> _contacts = [
    Contact(name: 'Abhay Singh', avatarUrl: 'https://i.pravatar.cc/150?u=abhay', isSelected: true),
    Contact(name: 'Chirag', avatarUrl: ''),
    Contact(name: 'Kirti Gupta', avatarUrl: 'https://i.pravatar.cc/150?u=kirti'),
    Contact(name: 'Siya', avatarUrl: 'https://i.pravatar.cc/150?u=siya', isSelected: true),
    Contact(name: 'Tarushi Jain', avatarUrl: 'https://i.pravatar.cc/150?u=tarushi'),
  ];

  String _searchQuery = '';

  List<Contact> get _selectedContacts => _contacts.where((c) => c.isSelected).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Friends',
          style: TextStyle(
            color: AppColors.textDark,
            fontFamily: 'SF Pro',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.inputBgGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontFamily: 'SF Pro',
                    fontSize: 15,
                  ),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: AppColors.textGrey, size: 20),
                    hintText: 'Search Contacts',
                    hintStyle: TextStyle(
                      color: AppColors.textGrey,
                      fontFamily: 'SF Pro',
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Friends to Add Section
            if (_selectedContacts.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 12.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Friends to Add',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _selectedContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _selectedContacts[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.avatarBgGrey,
                                backgroundImage: contact.avatarUrl.isNotEmpty
                                    ? NetworkImage(contact.avatarUrl)
                                    : null,
                                child: contact.avatarUrl.isEmpty
                                    ? Text(
                                        contact.name[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.textGrey,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'SF Pro',
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                top: -2,
                                right: -2,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      contact.isSelected = false;
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE94A4A), // Distinct error/remove red
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: const Icon(
                                      Icons.close,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            contact.name.split(' ').first,
                            style: const TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 12,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(color: AppColors.inputBgGrey, thickness: 1, indent: 20, endIndent: 20),
            ],

            // Invite via Direct Share
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.link, color: AppColors.primaryGreen),
              title: const Text(
                'Invite via Direct Share',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
              onTap: () {},
            ),

            const Divider(color: AppColors.inputBgGrey, thickness: 1, indent: 20, endIndent: 20),

            // From your Contacts
            const Padding(
              padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'From your Contacts',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  // Basic search filter
                  if (_searchQuery.isNotEmpty && 
                      !contact.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.avatarBgGrey,
                      backgroundImage: contact.avatarUrl.isNotEmpty
                          ? NetworkImage(contact.avatarUrl)
                          : null,
                      child: contact.avatarUrl.isEmpty
                          ? Text(
                              contact.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'SF Pro',
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      contact.name,
                      style: const TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                    trailing: contact.isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 26)
                        : const Icon(Icons.circle_outlined, color: AppColors.textGrey, size: 26),
                    onTap: () {
                      setState(() {
                        contact.isSelected = !contact.isSelected;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        onPressed: () {
          // Finish friends setup
        },
        label: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Add',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white, 
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
