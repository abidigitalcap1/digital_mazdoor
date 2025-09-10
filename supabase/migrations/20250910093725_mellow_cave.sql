/*
  # NanoLancers Database Schema

  1. New Tables
    - `users` - User profiles and authentication
    - `courses` - Course information and details
    - `blog_posts` - Tech blog posts with bilingual content
    - `ai_tools` - AI tools directory
    - `enrollments` - Course enrollments tracking
    - `newsletter_subscribers` - Email newsletter subscriptions
    - `testimonials` - User testimonials and reviews
    - `course_lessons` - Individual course lessons
    - `blog_comments` - Blog post comments
    - `user_progress` - Course progress tracking

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
    - Public read access for published content
    - Admin-only access for management operations

  3. Features
    - Full-text search capabilities
    - Automatic timestamps
    - Proper indexing for performance
    - Foreign key relationships
*/

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  full_name text NOT NULL,
  phone text,
  location text,
  role text DEFAULT 'student' CHECK (role IN ('student', 'instructor', 'admin')),
  avatar_url text,
  bio text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Courses table
CREATE TABLE IF NOT EXISTS courses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  title_urdu text,
  slug text UNIQUE NOT NULL,
  description text NOT NULL,
  instructor_id uuid REFERENCES users(id) ON DELETE CASCADE,
  instructor_name text NOT NULL,
  category text NOT NULL,
  price decimal(10,2) NOT NULL DEFAULT 0,
  original_price decimal(10,2),
  duration text NOT NULL,
  lessons_count integer DEFAULT 0,
  level text DEFAULT 'beginner' CHECK (level IN ('beginner', 'intermediate', 'advanced')),
  thumbnail_url text,
  preview_video_url text,
  features text[] DEFAULT '{}',
  requirements text[] DEFAULT '{}',
  what_you_learn text[] DEFAULT '{}',
  status text DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  is_bestseller boolean DEFAULT false,
  is_featured boolean DEFAULT false,
  rating decimal(3,2) DEFAULT 0,
  students_count integer DEFAULT 0,
  total_revenue decimal(12,2) DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Course lessons table
CREATE TABLE IF NOT EXISTS course_lessons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  title text NOT NULL,
  title_urdu text,
  description text,
  video_url text,
  duration text,
  order_index integer NOT NULL,
  is_preview boolean DEFAULT false,
  content text,
  resources text[] DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Blog posts table
CREATE TABLE IF NOT EXISTS blog_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  title_urdu text,
  slug text UNIQUE NOT NULL,
  excerpt text NOT NULL,
  content text NOT NULL,
  author_id uuid REFERENCES users(id) ON DELETE CASCADE,
  author_name text NOT NULL,
  category text NOT NULL,
  tags text[] DEFAULT '{}',
  thumbnail_url text,
  status text DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  is_featured boolean DEFAULT false,
  views_count integer DEFAULT 0,
  read_time text DEFAULT '5 min read',
  seo_title text,
  seo_description text,
  published_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- AI tools table
CREATE TABLE IF NOT EXISTS ai_tools (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text UNIQUE NOT NULL,
  category text NOT NULL,
  description text NOT NULL,
  description_urdu text,
  website_url text NOT NULL,
  thumbnail_url text,
  price text NOT NULL,
  users_count text DEFAULT '0',
  rating decimal(3,2) DEFAULT 0,
  features text[] DEFAULT '{}',
  pros text[] DEFAULT '{}',
  cons text[] DEFAULT '{}',
  status text DEFAULT 'pending' CHECK (status IN ('active', 'pending', 'inactive')),
  is_featured boolean DEFAULT false,
  is_editors_choice boolean DEFAULT false,
  views_count integer DEFAULT 0,
  affiliate_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enrollments table
CREATE TABLE IF NOT EXISTS enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  enrolled_at timestamptz DEFAULT now(),
  progress integer DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
  completed_at timestamptz,
  status text DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
  payment_status text DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
  amount_paid decimal(10,2),
  UNIQUE(user_id, course_id)
);

-- User progress table
CREATE TABLE IF NOT EXISTS user_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  lesson_id uuid REFERENCES course_lessons(id) ON DELETE CASCADE,
  completed_at timestamptz DEFAULT now(),
  watch_time integer DEFAULT 0,
  UNIQUE(user_id, lesson_id)
);

-- Newsletter subscribers table
CREATE TABLE IF NOT EXISTS newsletter_subscribers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  subscribed_at timestamptz DEFAULT now(),
  is_active boolean DEFAULT true,
  unsubscribed_at timestamptz
);

-- Testimonials table
CREATE TABLE IF NOT EXISTS testimonials (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  user_name text NOT NULL,
  user_title text,
  user_avatar text,
  content text NOT NULL,
  content_urdu text,
  rating integer DEFAULT 5 CHECK (rating >= 1 AND rating <= 5),
  is_featured boolean DEFAULT false,
  is_approved boolean DEFAULT false,
  course_id uuid REFERENCES courses(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

-- Blog comments table
CREATE TABLE IF NOT EXISTS blog_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  blog_post_id uuid REFERENCES blog_posts(id) ON DELETE CASCADE,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  user_name text NOT NULL,
  content text NOT NULL,
  is_approved boolean DEFAULT false,
  parent_id uuid REFERENCES blog_comments(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_courses_status ON courses(status);
CREATE INDEX IF NOT EXISTS idx_courses_category ON courses(category);
CREATE INDEX IF NOT EXISTS idx_courses_instructor ON courses(instructor_id);
CREATE INDEX IF NOT EXISTS idx_blog_posts_status ON blog_posts(status);
CREATE INDEX IF NOT EXISTS idx_blog_posts_category ON blog_posts(category);
CREATE INDEX IF NOT EXISTS idx_blog_posts_author ON blog_posts(author_id);
CREATE INDEX IF NOT EXISTS idx_ai_tools_category ON ai_tools(category);
CREATE INDEX IF NOT EXISTS idx_ai_tools_status ON ai_tools(status);
CREATE INDEX IF NOT EXISTS idx_enrollments_user ON enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course ON enrollments(course_id);

-- Full-text search indexes
CREATE INDEX IF NOT EXISTS idx_courses_search ON courses USING gin(to_tsvector('english', title || ' ' || description));
CREATE INDEX IF NOT EXISTS idx_blog_posts_search ON blog_posts USING gin(to_tsvector('english', title || ' ' || content));
CREATE INDEX IF NOT EXISTS idx_ai_tools_search ON ai_tools USING gin(to_tsvector('english', name || ' ' || description));

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_tools ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE newsletter_subscribers ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog_comments ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users policies
CREATE POLICY "Users can read own profile" ON users
  FOR SELECT TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE TO authenticated
  USING (auth.uid() = id);

-- Courses policies (public read for published courses)
CREATE POLICY "Anyone can read published courses" ON courses
  FOR SELECT
  USING (status = 'published');

CREATE POLICY "Instructors can manage own courses" ON courses
  FOR ALL TO authenticated
  USING (instructor_id = auth.uid());

-- Course lessons policies
CREATE POLICY "Anyone can read lessons of published courses" ON course_lessons
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM courses 
      WHERE courses.id = course_lessons.course_id 
      AND courses.status = 'published'
    )
  );

-- Blog posts policies (public read for published posts)
CREATE POLICY "Anyone can read published blog posts" ON blog_posts
  FOR SELECT
  USING (status = 'published');

CREATE POLICY "Authors can manage own blog posts" ON blog_posts
  FOR ALL TO authenticated
  USING (author_id = auth.uid());

-- AI tools policies (public read for active tools)
CREATE POLICY "Anyone can read active AI tools" ON ai_tools
  FOR SELECT
  USING (status = 'active');

-- Enrollments policies
CREATE POLICY "Users can read own enrollments" ON enrollments
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can create own enrollments" ON enrollments
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

-- User progress policies
CREATE POLICY "Users can manage own progress" ON user_progress
  FOR ALL TO authenticated
  USING (user_id = auth.uid());

-- Newsletter policies (public insert)
CREATE POLICY "Anyone can subscribe to newsletter" ON newsletter_subscribers
  FOR INSERT
  WITH CHECK (true);

-- Testimonials policies (public read for approved)
CREATE POLICY "Anyone can read approved testimonials" ON testimonials
  FOR SELECT
  USING (is_approved = true);

CREATE POLICY "Users can create own testimonials" ON testimonials
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Blog comments policies (public read for approved)
CREATE POLICY "Anyone can read approved comments" ON blog_comments
  FOR SELECT
  USING (is_approved = true);

CREATE POLICY "Users can create own comments" ON blog_comments
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Functions for automatic updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_courses_updated_at BEFORE UPDATE ON courses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_course_lessons_updated_at BEFORE UPDATE ON course_lessons FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_blog_posts_updated_at BEFORE UPDATE ON blog_posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ai_tools_updated_at BEFORE UPDATE ON ai_tools FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update course stats
CREATE OR REPLACE FUNCTION update_course_stats()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE courses 
    SET students_count = students_count + 1
    WHERE id = NEW.course_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE courses 
    SET students_count = students_count - 1
    WHERE id = OLD.course_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

CREATE TRIGGER update_course_enrollment_stats
  AFTER INSERT OR DELETE ON enrollments
  FOR EACH ROW EXECUTE FUNCTION update_course_stats();

-- Function to update blog post views
CREATE OR REPLACE FUNCTION increment_blog_views(post_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE blog_posts 
  SET views_count = views_count + 1 
  WHERE id = post_id;
END;
$$ language 'plpgsql';

-- Function to update AI tool views
CREATE OR REPLACE FUNCTION increment_tool_views(tool_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE ai_tools 
  SET views_count = views_count + 1 
  WHERE id = tool_id;
END;
$$ language 'plpgsql';