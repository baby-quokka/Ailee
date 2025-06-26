from rest_framework import serializers
from .models import ChatSession, Message
from character.models import Character

class ChatSerializer(serializers.ModelSerializer):
    class Meta:  # TODO: Meta 클래스 추가
        model = ChatSession
        fields = ('character', 'user', 'summary', 'topic', 'time')

class MessageSerializer(serializers.ModelSerializer):
    class Meta:  # TODO: Meta 클래스 추가
        model = Message
        fields = ('session', 'sender','message','order')