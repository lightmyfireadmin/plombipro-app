"""
Shared authentication utilities for Cloud Functions.
Verifies Supabase JWT tokens and extracts user information.
"""
import os
import jwt
from jwt import PyJWTError
from functools import wraps
from flask import request, jsonify
from typing import Optional, Dict, Any, Callable


def get_supabase_jwt_secret() -> str:
    """Get Supabase JWT secret from environment."""
    secret = os.environ.get('SUPABASE_JWT_SECRET')
    if not secret:
        raise ValueError('SUPABASE_JWT_SECRET environment variable not set')
    return secret


def verify_supabase_token(token: str) -> Optional[Dict[str, Any]]:
    """
    Verify a Supabase JWT token and return the decoded payload.

    Args:
        token: The JWT token string

    Returns:
        Decoded token payload if valid, None if invalid
    """
    try:
        secret = get_supabase_jwt_secret()
        # Verify and decode the token
        payload = jwt.decode(
            token,
            secret,
            algorithms=['HS256'],
            options={
                'verify_signature': True,
                'verify_exp': True,
                'verify_aud': True,
                'require': ['sub', 'exp']
            },
            audience='authenticated'
        )
        return payload
    except PyJWTError as e:
        print(f"JWT verification failed: {str(e)}")
        return None
    except Exception as e:
        print(f"Unexpected error during token verification: {str(e)}")
        return None


def extract_user_id(payload: Dict[str, Any]) -> Optional[str]:
    """
    Extract user ID from decoded JWT payload.

    Args:
        payload: Decoded JWT payload

    Returns:
        User ID (UUID) if present, None otherwise
    """
    return payload.get('sub')


def get_auth_token(request) -> Optional[str]:
    """
    Extract authentication token from request headers.
    Supports both 'Authorization: Bearer <token>' and 'Authorization: <token>' formats.

    Args:
        request: Flask request object

    Returns:
        Token string if found, None otherwise
    """
    auth_header = request.headers.get('Authorization')
    if not auth_header:
        return None

    # Handle "Bearer <token>" format
    if auth_header.startswith('Bearer '):
        return auth_header[7:]

    # Handle direct token format
    return auth_header


def require_auth(f: Callable) -> Callable:
    """
    Decorator to require authentication for Cloud Functions.

    Usage:
        @require_auth
        def my_function(request):
            user_id = request.user_id  # Access authenticated user ID
            # ... function logic

    The decorator will:
    - Extract and verify the JWT token from Authorization header
    - Return 401 if token is missing or invalid
    - Inject user_id into the request object for use in the function
    """
    @wraps(f)
    def decorated_function(request):
        # Extract token from request
        token = get_auth_token(request)
        if not token:
            return jsonify({
                'error': 'Authentication required',
                'message': 'Missing Authorization header'
            }), 401

        # Verify token
        payload = verify_supabase_token(token)
        if not payload:
            return jsonify({
                'error': 'Authentication failed',
                'message': 'Invalid or expired token'
            }), 401

        # Extract user ID
        user_id = extract_user_id(payload)
        if not user_id:
            return jsonify({
                'error': 'Authentication failed',
                'message': 'Token missing user ID'
            }), 401

        # Inject user_id into request for use in function
        request.user_id = user_id
        request.user_payload = payload

        # Call the original function
        return f(request)

    return decorated_function


def verify_user_ownership(user_id: str, resource_user_id: str) -> bool:
    """
    Verify that the authenticated user owns the resource.

    Args:
        user_id: Authenticated user's ID
        resource_user_id: User ID associated with the resource

    Returns:
        True if user owns resource, False otherwise
    """
    return user_id == resource_user_id
