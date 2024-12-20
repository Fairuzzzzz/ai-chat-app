# AI Ally

## Overview

AI Ally is a Flutter-based mobile application that provides an interactive chat interface powered by the Groq AI model. The application allows users to have conversations with an AI assistant while maintaining chat history and session management.

![image alt](https://github.com/Fairuzzzzz/ai-chat-app/blob/main/screenshot/Frame.png?raw=true)

## Features

- User Authentication (Sign up/Login)
- Real-time AI chat interactions
- Chat session management
- Message history storage
- Copy message functionality

## Technical Stack

- **Frontend**: Flutter
- **Backend**: Supabase
- **AI Model**: Groq LLM (llama-3.1-70b-versatile)
- **Authentication** Supabase Auth
- **Database**: Supabase PostgreSQL

## Architecture

The application follows a service-based architecture with clear separation of concerns:

### Core Services

1. **AuthService**: Handles user authentication
2. **ChatService**: Manages chat operations and history
3. **AIService**: Interfaces with Groq API
4. **ChatModel**: Data model for chat messages

### Key Components

- **Home**: Main chat interface
- **AuthGate**: Authentication flow controller
- **WelcomeLoginPage**: User login interface
- **RegisterPage**: User registration interface

## Environment Configuration

Required environment variables (.env):

```env
SUPABASE_URL=<your-supabase-url>
SUPABASE_KEY=<your-supabase-key>
GROQ_API=<your-groq-api-key>
```
