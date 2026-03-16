<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Room;
use App\Models\Message;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Create Default Users (Alice, Bob, Charlie)
        $alice = User::create([
            'name' => 'Alice Admin',
            'email' => 'alice@example.com',
            'password' => Hash::make('password'),
            'phone' => '1234567890',
        ]);

        $bob = User::create([
            'name' => 'Bob Member',
            'email' => 'bob@example.com',
            'password' => Hash::make('password'),
            'phone' => '9876543210',
        ]);

        $charlie = User::create([
            'name' => 'Charlie Smith',
            'email' => 'charlie@example.com',
            'password' => Hash::make('password'),
            'phone' => '5555555555',
        ]);

        // 2. Create extra random users for testing
        User::factory(5)->create();

        // 3. Create a Demo Group
        $group = Room::create([
            'name' => 'Webmyne Developers',
            'type' => 2, // Group
            'description' => 'Official group for project coordination and announcements.',
            'created_by' => $alice->id,
        ]);

        // 4. Attach Members to Group
        $group->members()->attach($alice->id, ['role' => 'admin', 'created_at' => now()]);
        $group->members()->attach($bob->id, ['role' => 'member', 'created_at' => now()]);
        $group->members()->attach($charlie->id, ['role' => 'member', 'created_at' => now()]);

        // 5. Create some initial group messages
        Message::create([
            'room_id' => $group->id,
            'sender_id' => $alice->id,
            'content' => 'Alice Admin created the group "Webmyne Developers"',
            'type' => 'system',
            'created_at' => now()->subMinutes(10)
        ]);

        Message::create([
            'room_id' => $group->id,
            'sender_id' => $alice->id,
            'content' => 'Alice Admin added Bob Member',
            'type' => 'system',
            'created_at' => now()->subMinutes(9)
        ]);

        Message::create([
            'room_id' => $group->id,
            'sender_id' => $alice->id,
            'content' => 'Alice Admin added Charlie Smith',
            'type' => 'system',
            'created_at' => now()->subMinutes(8)
        ]);

        Message::create([
            'room_id' => $group->id,
            'sender_id' => $alice->id,
            'content' => 'Hello team! Welcome to the new communication hub.',
            'type' => 'text',
            'created_at' => now()->subMinutes(5)
        ]);

        Message::create([
            'room_id' => $group->id,
            'sender_id' => $bob->id,
            'content' => 'Thanks Alice! This looks great.',
            'type' => 'text',
            'created_at' => now()->subMinutes(2)
        ]);

        // 6. Create some private messages between Alice and Bob
        Message::create([
            'sender_id' => $alice->id,
            'receiver_id' => $bob->id,
            'content' => 'Hey Bob, did you see the new features?',
            'type' => 'text',
            'created_at' => now()->subHour()
        ]);

        Message::create([
            'sender_id' => $bob->id,
            'receiver_id' => $alice->id,
            'content' => 'Yes, the notifications are awesome!',
            'type' => 'text',
            'created_at' => now()->subMinutes(30)
        ]);

        // 7. Generate some utility data for Alice
        $alice->reminders()->create([
            'title' => 'Project Deadline',
            'reminder_date' => now()->addDays(2),
            'status' => 'pending'
        ]);

        $alice->notes()->create([
            'title' => 'Meeting Notes',
            'content' => 'Discussed the real-time notification architecture.',
            'is_pinned' => true
        ]);

        $alice->bills()->create([
            'title' => 'Electricity Bill',
            'amount' => 1500,
            'due_date' => now()->addDays(5),
            'status' => 'unpaid',
            'bill_type' => 'Electricity'
        ]);
    }
}
