import { useState, useEffect } from 'react'
import { supabase, type User, type Course, type BlogPost, type AITool } from '../lib/supabase'

// Custom hook for authentication
export const useAuth = () => {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user as User || null)
      setLoading(false)
    })

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        setUser(session?.user as User || null)
        setLoading(false)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  const signUp = async (email: string, password: string, fullName: string) => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
        }
      }
    })
    return { data, error }
  }

  const signIn = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    return { data, error }
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    return { error }
  }

  return {
    user,
    loading,
    signUp,
    signIn,
    signOut,
  }
}

// Custom hook for courses
export const useCourses = () => {
  const [courses, setCourses] = useState<Course[]>([])
  const [loading, setLoading] = useState(true)

  const fetchCourses = async (filters?: { category?: string; status?: string }) => {
    setLoading(true)
    let query = supabase
      .from('courses')
      .select('*')
      .order('created_at', { ascending: false })

    if (filters?.category && filters.category !== 'All') {
      query = query.eq('category', filters.category)
    }
    if (filters?.status && filters.status !== 'All') {
      query = query.eq('status', filters.status)
    }

    const { data, error } = await query
    if (!error && data) {
      setCourses(data)
    }
    setLoading(false)
    return { data, error }
  }

  const createCourse = async (courseData: Partial<Course>) => {
    const { data, error } = await supabase
      .from('courses')
      .insert([courseData])
      .select()
    
    if (!error && data) {
      setCourses(prev => [data[0], ...prev])
    }
    return { data, error }
  }

  const updateCourse = async (id: string, updates: Partial<Course>) => {
    const { data, error } = await supabase
      .from('courses')
      .update(updates)
      .eq('id', id)
      .select()
    
    if (!error && data) {
      setCourses(prev => prev.map(course => 
        course.id === id ? { ...course, ...data[0] } : course
      ))
    }
    return { data, error }
  }

  const deleteCourse = async (id: string) => {
    const { error } = await supabase
      .from('courses')
      .delete()
      .eq('id', id)
    
    if (!error) {
      setCourses(prev => prev.filter(course => course.id !== id))
    }
    return { error }
  }

  useEffect(() => {
    fetchCourses()
  }, [])

  return {
    courses,
    loading,
    fetchCourses,
    createCourse,
    updateCourse,
    deleteCourse,
  }
}

// Custom hook for blog posts
export const useBlogPosts = () => {
  const [posts, setPosts] = useState<BlogPost[]>([])
  const [loading, setLoading] = useState(true)

  const fetchPosts = async (filters?: { category?: string; status?: string }) => {
    setLoading(true)
    let query = supabase
      .from('blog_posts')
      .select('*')
      .order('created_at', { ascending: false })

    if (filters?.category && filters.category !== 'All') {
      query = query.eq('category', filters.category)
    }
    if (filters?.status && filters.status !== 'All') {
      query = query.eq('status', filters.status)
    }

    const { data, error } = await query
    if (!error && data) {
      setPosts(data)
    }
    setLoading(false)
    return { data, error }
  }

  const createPost = async (postData: Partial<BlogPost>) => {
    const { data, error } = await supabase
      .from('blog_posts')
      .insert([postData])
      .select()
    
    if (!error && data) {
      setPosts(prev => [data[0], ...prev])
    }
    return { data, error }
  }

  const updatePost = async (id: string, updates: Partial<BlogPost>) => {
    const { data, error } = await supabase
      .from('blog_posts')
      .update(updates)
      .eq('id', id)
      .select()
    
    if (!error && data) {
      setPosts(prev => prev.map(post => 
        post.id === id ? { ...post, ...data[0] } : post
      ))
    }
    return { data, error }
  }

  const deletePost = async (id: string) => {
    const { error } = await supabase
      .from('blog_posts')
      .delete()
      .eq('id', id)
    
    if (!error) {
      setPosts(prev => prev.filter(post => post.id !== id))
    }
    return { error }
  }

  const incrementViews = async (id: string) => {
    await supabase.rpc('increment_blog_views', { post_id: id })
  }

  useEffect(() => {
    fetchPosts()
  }, [])

  return {
    posts,
    loading,
    fetchPosts,
    createPost,
    updatePost,
    deletePost,
    incrementViews,
  }
}

// Custom hook for AI tools
export const useAITools = () => {
  const [tools, setTools] = useState<AITool[]>([])
  const [loading, setLoading] = useState(true)

  const fetchTools = async (filters?: { category?: string; status?: string }) => {
    setLoading(true)
    let query = supabase
      .from('ai_tools')
      .select('*')
      .order('created_at', { ascending: false })

    if (filters?.category && filters.category !== 'All') {
      query = query.eq('category', filters.category)
    }
    if (filters?.status && filters.status !== 'All') {
      query = query.eq('status', filters.status)
    }

    const { data, error } = await query
    if (!error && data) {
      setTools(data)
    }
    setLoading(false)
    return { data, error }
  }

  const createTool = async (toolData: Partial<AITool>) => {
    const { data, error } = await supabase
      .from('ai_tools')
      .insert([toolData])
      .select()
    
    if (!error && data) {
      setTools(prev => [data[0], ...prev])
    }
    return { data, error }
  }

  const updateTool = async (id: string, updates: Partial<AITool>) => {
    const { data, error } = await supabase
      .from('ai_tools')
      .update(updates)
      .eq('id', id)
      .select()
    
    if (!error && data) {
      setTools(prev => prev.map(tool => 
        tool.id === id ? { ...tool, ...data[0] } : tool
      ))
    }
    return { data, error }
  }

  const deleteTool = async (id: string) => {
    const { error } = await supabase
      .from('ai_tools')
      .delete()
      .eq('id', id)
    
    if (!error) {
      setTools(prev => prev.filter(tool => tool.id !== id))
    }
    return { error }
  }

  const incrementViews = async (id: string) => {
    await supabase.rpc('increment_tool_views', { tool_id: id })
  }

  useEffect(() => {
    fetchTools()
  }, [])

  return {
    tools,
    loading,
    fetchTools,
    createTool,
    updateTool,
    deleteTool,
    incrementViews,
  }
}

// Newsletter subscription hook
export const useNewsletter = () => {
  const subscribe = async (email: string) => {
    const { data, error } = await supabase
      .from('newsletter_subscribers')
      .insert([{ email }])
      .select()
    
    return { data, error }
  }

  return { subscribe }
}