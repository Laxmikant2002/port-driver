import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/screens/account_screen/bloc/account_bloc.dart';
import 'package:driver/routes/settings_routes.dart';
import 'package:image_picker/image_picker.dart';

class AccountScreen extends StatelessWidget {
    const AccountScreen({super.key});

    static const List<Map<String, dynamic>> buttonsData = [
        {'text': "Rides", 'icon': Icons.directions_car, 'route': '/rides-history'},
        {'text': 'Ratings', 'icon': Icons.star_outline, 'route': '/ratings'},
        {'text': 'Wallet', 'icon': Icons.wallet, 'route': '/payment-overview'},
        {'text': 'Documents', 'icon': Icons.file_present, 'route': '/document-screen'},
        {'text': 'Add Vehicle', 'icon': Icons.add_circle_outline, 'route': '/add-vehicle'},
        {'text': "Settings", 'icon': Icons.settings, 'route': SettingsRoutes.settings},
    ];

    @override
    Widget build(BuildContext context) {
        return BlocProvider(
            create: (context) => AccountBloc()..add(LoadAccountData()),
            child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    title: const Text(
        'Account',
        style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
        ),
    ),
    centerTitle: true,
    actions: [
        IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
                Navigator.pushNamed(context, '/inbox');
            },
        ),
    ],
),

                body: BlocConsumer<AccountBloc, AccountState>(
                    listener: (context, state) {
                        if (state is AccountError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.message)),
                            );
                        } else if (state is AccountLoggedOut) {
                            Navigator.of(context).pushReplacementNamed('/login');
                        }
                    },
                    builder: (context, state) {
                        if (state is AccountLoading) {
                            return const Center(child: CircularProgressIndicator());
                        }
                        if (state is AccountLoaded) {
                            return _buildAccountContent(context, state);
                        }
                        return const Center(child: Text('Something went wrong'));
                    },
                ),
            ),
        );
    }

    Widget _buildAccountContent(BuildContext context, AccountLoaded state) {
        return SingleChildScrollView(
            child: Column(
                children: [
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                ),
                            ),
                        ),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                state.name ?? 'User',
                                                style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                                state.vehicle ?? 'No vehicle added',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[600],
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                        Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.grey[200]!,
                                                    width: 2,
                                                ),
                                            ),
                                            child: ClipOval(
                                                child: state.profileImage != null
                                                    ? Image.network(
                                                        state.profileImage!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                            return Icon(
                                                                Icons.account_circle,
                                                                size: 80,
                                                                color: Colors.grey[400],
                                                            );
                                                        },
                                                    )
                                                    : Icon(
                                                        Icons.account_circle,
                                                        size: 80,
                                                        color: Colors.grey[400],
                                                    ),
                                            ),
                                        ),
                                        Container(
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                ),
                                            ),
                                            child: IconButton(
                                                icon: const Icon(
                                                    Icons.camera_alt,
                                                    size: 20,
                                                    color: Colors.white,
                                                ),
                                                onPressed: () => _handleProfileImageUpdate(context),
                                            ),
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                            children: [
                                ...buttonsData.map((button) => Column(
                                    children: [
                                        Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: Colors.grey[200]!,
                                                ),
                                            ),
                                            child: ListTile(
                                                leading: Icon(
                                                    button['icon'] as IconData,
                                                    color: Colors.black,
                                                ),
                                                title: Text(
                                                    button['text'] as String,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.black,
                                                    ),
                                                ),
                                                trailing: const Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.grey,
                                                ),
                                                onTap: () => Navigator.pushNamed(
                                                    context,
                                                    button['route'] as String,
                                                ),
                                            ),
                                        ),
                                        const SizedBox(height: 16),
                                    ],
                                )).toList(),
                                _buildLogoutButton(context),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildLogoutButton(BuildContext context) {
        return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                    context.read<AccountBloc>().add(LogoutRequested());
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                    ),
                ),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.logout_outlined),
                        SizedBox(width: 8),
                        Text(
                            'Logout',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    Future<void> _handleProfileImageUpdate(BuildContext context) async {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);

        if (image != null && context.mounted) {
            context.read<AccountBloc>().add(UpdateProfileImage(image.path));
        }
    }
}
