-- MySQL Schema for NanoLancers Platform
-- Compatible with MySQL 8.0+

-- Create database
CREATE DATABASE IF NOT EXISTS nanolancers CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE nanolancers;

-- Users table
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    location VARCHAR(255),
    role ENUM('student', 'instructor', 'admin') DEFAULT 'student',
    avatar_url TEXT,
    bio TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_created_at (created_at)
);

-- Courses table
CREATE TABLE courses (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    title VARCHAR(500) NOT NULL,
    title_urdu VARCHAR(500),
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    instructor_id CHAR(36) NOT NULL,
    instructor_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL DEFAULT 0,
    original_price DECIMAL(10,2),
    duration VARCHAR(50) NOT NULL,
    lessons_count INT DEFAULT 0,
    level ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'beginner',
    thumbnail_url TEXT,
    preview_video_url TEXT,
    features JSON,
    requirements JSON,
    what_you_learn JSON,
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft',
    is_bestseller BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    rating DECIMAL(3,2) DEFAULT 0,
    students_count INT DEFAULT 0,
    total_revenue DECIMAL(12,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (instructor_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_category (category),
    INDEX idx_instructor (instructor_id),
    INDEX idx_featured (is_featured),
    INDEX idx_bestseller (is_bestseller),
    FULLTEXT idx_search (title, description)
);

-- Course lessons table
CREATE TABLE course_lessons (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    course_id CHAR(36) NOT NULL,
    title VARCHAR(500) NOT NULL,
    title_urdu VARCHAR(500),
    description TEXT,
    video_url TEXT,
    duration VARCHAR(20),
    order_index INT NOT NULL,
    is_preview BOOLEAN DEFAULT FALSE,
    content LONGTEXT,
    resources JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    INDEX idx_course (course_id),
    INDEX idx_order (order_index)
);

-- Blog posts table
CREATE TABLE blog_posts (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    title VARCHAR(500) NOT NULL,
    title_urdu VARCHAR(500),
    slug VARCHAR(255) UNIQUE NOT NULL,
    excerpt TEXT NOT NULL,
    content LONGTEXT NOT NULL,
    author_id CHAR(36) NOT NULL,
    author_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    tags JSON,
    thumbnail_url TEXT,
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft',
    is_featured BOOLEAN DEFAULT FALSE,
    views_count INT DEFAULT 0,
    read_time VARCHAR(20) DEFAULT '5 min read',
    seo_title VARCHAR(255),
    seo_description TEXT,
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_category (category),
    INDEX idx_author (author_id),
    INDEX idx_featured (is_featured),
    INDEX idx_published (published_at),
    FULLTEXT idx_search (title, content)
);

-- AI tools table
CREATE TABLE ai_tools (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    description_urdu TEXT,
    website_url TEXT NOT NULL,
    thumbnail_url TEXT,
    price VARCHAR(50) NOT NULL,
    users_count VARCHAR(20) DEFAULT '0',
    rating DECIMAL(3,2) DEFAULT 0,
    features JSON,
    pros JSON,
    cons JSON,
    status ENUM('active', 'pending', 'inactive') DEFAULT 'pending',
    is_featured BOOLEAN DEFAULT FALSE,
    is_editors_choice BOOLEAN DEFAULT FALSE,
    views_count INT DEFAULT 0,
    affiliate_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_status (status),
    INDEX idx_featured (is_featured),
    INDEX idx_editors_choice (is_editors_choice),
    FULLTEXT idx_search (name, description)
);

-- Enrollments table
CREATE TABLE enrollments (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    course_id CHAR(36) NOT NULL,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    progress INT DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    completed_at TIMESTAMP NULL,
    status ENUM('active', 'completed', 'cancelled') DEFAULT 'active',
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    amount_paid DECIMAL(10,2),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (user_id, course_id),
    INDEX idx_user (user_id),
    INDEX idx_course (course_id),
    INDEX idx_status (status)
);

-- User progress table
CREATE TABLE user_progress (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    course_id CHAR(36) NOT NULL,
    lesson_id CHAR(36) NOT NULL,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    watch_time INT DEFAULT 0,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES course_lessons(id) ON DELETE CASCADE,
    UNIQUE KEY unique_progress (user_id, lesson_id),
    INDEX idx_user_course (user_id, course_id)
);

-- Newsletter subscribers table
CREATE TABLE newsletter_subscribers (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    email VARCHAR(255) UNIQUE NOT NULL,
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    unsubscribed_at TIMESTAMP NULL,
    
    INDEX idx_email (email),
    INDEX idx_active (is_active)
);

-- Testimonials table
CREATE TABLE testimonials (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36),
    user_name VARCHAR(255) NOT NULL,
    user_title VARCHAR(255),
    user_avatar TEXT,
    content TEXT NOT NULL,
    content_urdu TEXT,
    rating INT DEFAULT 5 CHECK (rating >= 1 AND rating <= 5),
    is_featured BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    course_id CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL,
    INDEX idx_featured (is_featured),
    INDEX idx_approved (is_approved)
);

-- Blog comments table
CREATE TABLE blog_comments (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    blog_post_id CHAR(36) NOT NULL,
    user_id CHAR(36),
    user_name VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    is_approved BOOLEAN DEFAULT FALSE,
    parent_id CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (blog_post_id) REFERENCES blog_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (parent_id) REFERENCES blog_comments(id) ON DELETE CASCADE,
    INDEX idx_post (blog_post_id),
    INDEX idx_approved (is_approved),
    INDEX idx_parent (parent_id)
);

-- Create triggers for updating course stats
DELIMITER //

CREATE TRIGGER update_course_enrollment_stats_insert
AFTER INSERT ON enrollments
FOR EACH ROW
BEGIN
    UPDATE courses 
    SET students_count = students_count + 1
    WHERE id = NEW.course_id;
END//

CREATE TRIGGER update_course_enrollment_stats_delete
AFTER DELETE ON enrollments
FOR EACH ROW
BEGIN
    UPDATE courses 
    SET students_count = students_count - 1
    WHERE id = OLD.course_id;
END//

DELIMITER ;

-- Insert sample data
INSERT INTO users (id, email, full_name, role) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'admin@nanolancers.com', 'Admin User', 'admin'),
('550e8400-e29b-41d4-a716-446655440002', 'ahmed.khan@nanolancers.com', 'Ahmed Khan', 'instructor'),
('550e8400-e29b-41d4-a716-446655440003', 'fatima.ali@nanolancers.com', 'Fatima Ali', 'instructor');

-- Insert sample courses
INSERT INTO courses (id, title, title_urdu, slug, description, instructor_id, instructor_name, category, price, duration, lessons_count, status, is_bestseller) VALUES
('550e8400-e29b-41d4-a716-446655440101', 'Complete AI Tools Mastery Course', 'مکمل AI ٹولز مہارت کورس', 'ai-tools-mastery', 'Master 50+ AI tools for content creation, business automation, and productivity', '550e8400-e29b-41d4-a716-446655440002', 'Ahmed Khan', 'AI Tools', 15000.00, '12 hours', 45, 'published', TRUE),
('550e8400-e29b-41d4-a716-446655440102', 'Digital Marketing Bootcamp', 'ڈیجیٹل مارکیٹنگ بوٹ کیمپ', 'digital-marketing-bootcamp', 'Complete digital marketing course covering SEO, social media, and paid advertising', '550e8400-e29b-41d4-a716-446655440003', 'Fatima Ali', 'Marketing', 20000.00, '20 hours', 60, 'published', FALSE);

-- Insert sample blog posts
INSERT INTO blog_posts (id, title, title_urdu, slug, excerpt, content, author_id, author_name, category, status, is_featured, published_at) VALUES
('550e8400-e29b-41d4-a716-446655440201', 'AI Tools Every Pakistani Entrepreneur Should Use in 2024', '2024 میں ہر پاکستانی کاروباری کے لیے ضروری AI ٹولز', 'ai-tools-pakistani-entrepreneurs-2024', 'Discover the top AI tools that are transforming businesses across Pakistan', 'Complete blog content here...', '550e8400-e29b-41d4-a716-446655440002', 'Ahmed Khan', 'AI Tools', 'published', TRUE, NOW());

-- Insert sample AI tools
INSERT INTO ai_tools (id, name, slug, category, description, description_urdu, website_url, price, rating, status, is_featured) VALUES
('550e8400-e29b-41d4-a716-446655440301', 'ChatGPT Plus', 'chatgpt-plus', 'AI Writing', 'Advanced AI assistant for content creation, coding, and problem-solving', 'کنٹینٹ بنانے، کوڈنگ اور مسائل حل کرنے کے لیے بہترین AI اسسٹنٹ', 'https://chat.openai.com', '$20/month', 4.9, 'active', TRUE);