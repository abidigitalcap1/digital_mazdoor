import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Database types
export interface User {
  id: string
  email: string
  full_name: string
  phone?: string
  location?: string
  role: 'student' | 'instructor' | 'admin'
  avatar_url?: string
  created_at: string
  updated_at: string
}

export interface Course {
  id: string
  title: string
  title_urdu: string
  description: string
  instructor_id: string
  instructor_name: string
  category: string
  price: number
  original_price?: number
  duration: string
  lessons_count: number
  level: string
  thumbnail_url: string
  features: string[]
  status: 'draft' | 'published' | 'archived'
  is_bestseller: boolean
  rating: number
  students_count: number
  created_at: string
  updated_at: string
}

export interface BlogPost {
  id: string
  title: string
  title_urdu: string
  slug: string
  excerpt: string
  content: string
  author_id: string
  author_name: string
  category: string
  tags: string[]
  thumbnail_url: string
  status: 'draft' | 'published' | 'archived'
  is_featured: boolean
  views_count: number
  read_time: string
  published_at?: string
  created_at: string
  updated_at: string
}

export interface AITool {
  id: string
  name: string
  category: string
  description: string
  description_urdu: string
  website_url: string
  thumbnail_url: string
  price: string
  users_count: string
  rating: number
  features: string[]
  status: 'active' | 'pending' | 'inactive'
  is_featured: boolean
  is_editors_choice: boolean
  views_count: number
  created_at: string
  updated_at: string
}

export interface Enrollment {
  id: string
  user_id: string
  course_id: string
  enrolled_at: string
  progress: number
  completed_at?: string
  status: 'active' | 'completed' | 'cancelled'
}

export interface Newsletter {
  id: string
  email: string
  subscribed_at: string
  is_active: boolean
}