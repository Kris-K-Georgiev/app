<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Post;
use App\Models\PostLike;
use App\Models\PostComment;
use App\Models\Prayer;
use App\Models\PrayerLike;
use App\Models\Feedback;
use Illuminate\Support\Facades\DB;

class SampleContentSeeder extends Seeder
{
    public function run(): void
    {
        // Ensure at least a few users exist
        if(User::count() < 5) {
            User::factory(5)->create();
        }

        $users = User::inRandomOrder()->take(5)->get();

        // Posts + likes + comments
        foreach(range(1,10) as $i) {
            $author = $users->random();
            $post = Post::create([
                'user_id' => $author->id,
                'content' => 'Sample post #'.$i.' lorem ipsum text',
                'image' => null,
            ]);
            // likes
            $likers = $users->shuffle()->take(rand(0,4));
            foreach($likers as $liker){
                PostLike::firstOrCreate(['post_id'=>$post->id,'user_id'=>$liker->id]);
            }
            // comments
            $commenters = $users->shuffle()->take(rand(0,3));
            foreach($commenters as $c){
                PostComment::create([
                    'post_id'=>$post->id,
                    'user_id'=>$c->id,
                    'content'=>'Comment from '.$c->name.' on post '.$post->id,
                ]);
            }
        }

        // Prayers + likes
        foreach(range(1,8) as $i){
            $author = $users->random();
            $prayer = Prayer::create([
                'user_id'=>$author->id,
                'content'=>'Prayer request #'.$i.' please pray for ...',
                'is_anonymous'=> (bool)rand(0,1),
                'answered'=> false,
            ]);
            $likers = $users->shuffle()->take(rand(0,4));
            foreach($likers as $liker){
                PrayerLike::firstOrCreate(['prayer_id'=>$prayer->id,'user_id'=>$liker->id]);
            }
        }

        // Feedback examples
        foreach(range(1,3) as $i){
            $u = $users->random();
            Feedback::create([
                'user_id'=>$u->id,
                'message'=>'Feedback sample #'.$i.' great app but consider feature X',
                'contact'=>$u->email,
                'user_agent'=>'seeder',
                'ip'=>'127.0.0.'.rand(2,200)
            ]);
        }
    }
}
