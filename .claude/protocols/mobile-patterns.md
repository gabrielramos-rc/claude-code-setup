---
name: mobile-patterns
description: >
  Mobile development patterns for React Native including navigation,
  state management, native modules, and platform-specific code.
applies_to: [engineer]
load_when: >
  Implementing mobile applications with React Native, handling navigation,
  platform-specific code, or integrating native modules.
---

# Mobile Patterns Protocol

## When to Use This Protocol

Load this protocol when:

- Building React Native applications
- Implementing mobile navigation
- Handling platform-specific code
- Integrating native modules
- Managing mobile app state
- Implementing offline support

**Do NOT load this protocol for:**
- Web-only React applications
- Mobile web (responsive) design
- Native iOS/Android without React Native

---

## React Native Project Structure

```
src/
├── components/          # Reusable UI components
│   ├── Button.tsx
│   └── Card.tsx
├── screens/             # Screen components
│   ├── HomeScreen.tsx
│   └── ProfileScreen.tsx
├── navigation/          # Navigation configuration
│   ├── AppNavigator.tsx
│   └── types.ts
├── hooks/               # Custom hooks
├── services/            # API and native services
├── store/               # State management
├── utils/               # Utilities
└── types/               # TypeScript types
```

---

## Navigation (React Navigation)

### Setup

```typescript
// src/navigation/AppNavigator.tsx
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

import { RootStackParamList, MainTabParamList } from './types';

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<MainTabParamList>();

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          const iconName = getIconName(route.name, focused);
          return <Icon name={iconName} size={size} color={color} />;
        },
      })}
    >
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Search" component={SearchScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
}

export function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen
          name="Main"
          component={MainTabs}
          options={{ headerShown: false }}
        />
        <Stack.Screen name="Details" component={DetailsScreen} />
        <Stack.Screen
          name="Modal"
          component={ModalScreen}
          options={{ presentation: 'modal' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

### Type-Safe Navigation

```typescript
// src/navigation/types.ts
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RouteProp } from '@react-navigation/native';

export type RootStackParamList = {
  Main: undefined;
  Details: { id: string; title: string };
  Modal: { message: string };
};

export type MainTabParamList = {
  Home: undefined;
  Search: { query?: string };
  Profile: undefined;
};

// Usage in screens
type DetailsScreenProps = {
  navigation: NativeStackNavigationProp<RootStackParamList, 'Details'>;
  route: RouteProp<RootStackParamList, 'Details'>;
};

function DetailsScreen({ navigation, route }: DetailsScreenProps) {
  const { id, title } = route.params;
  // ...
}
```

### Navigation Hooks

```typescript
// src/hooks/useNavigation.ts
import { useNavigation, useRoute } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../navigation/types';

export function useAppNavigation() {
  return useNavigation<NativeStackNavigationProp<RootStackParamList>>();
}

// Usage
function MyComponent() {
  const navigation = useAppNavigation();

  const handlePress = () => {
    navigation.navigate('Details', { id: '123', title: 'Item' });
  };
}
```

---

## Platform-Specific Code

### Platform Module

```typescript
// src/utils/platform.ts
import { Platform } from 'react-native';

export const isIOS = Platform.OS === 'ios';
export const isAndroid = Platform.OS === 'android';

export function platformSelect<T>(options: { ios: T; android: T; default?: T }): T {
  return Platform.select(options) ?? options.default ?? options.ios;
}

// Usage
const styles = StyleSheet.create({
  container: {
    paddingTop: platformSelect({ ios: 44, android: 0 }),
    elevation: platformSelect({ ios: 0, android: 4 }),
    shadowColor: platformSelect({ ios: '#000', android: 'transparent' }),
  },
});
```

### Platform-Specific Files

```
// React Native auto-selects based on extension
components/
├── Button.tsx           # Shared code
├── Button.ios.tsx       # iOS-specific
└── Button.android.tsx   # Android-specific
```

```typescript
// Button.ios.tsx
import { TouchableOpacity, Text } from 'react-native';

export function Button({ title, onPress }) {
  return (
    <TouchableOpacity onPress={onPress} style={styles.iosButton}>
      <Text>{title}</Text>
    </TouchableOpacity>
  );
}

// Button.android.tsx
import { Pressable, Text } from 'react-native';

export function Button({ title, onPress }) {
  return (
    <Pressable
      onPress={onPress}
      android_ripple={{ color: 'rgba(0,0,0,0.1)' }}
      style={styles.androidButton}
    >
      <Text>{title}</Text>
    </Pressable>
  );
}
```

---

## State Management

### Zustand Store

```typescript
// src/store/useAuthStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface AuthState {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isLoading: false,

      login: async (email, password) => {
        set({ isLoading: true });
        try {
          const response = await authApi.login(email, password);
          set({
            user: response.user,
            token: response.token,
            isLoading: false,
          });
        } catch (error) {
          set({ isLoading: false });
          throw error;
        }
      },

      logout: () => {
        set({ user: null, token: null });
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({ user: state.user, token: state.token }),
    }
  )
);
```

### React Query for Server State

```typescript
// src/hooks/useProducts.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { productApi } from '../services/api';

export function useProducts() {
  return useQuery({
    queryKey: ['products'],
    queryFn: productApi.getAll,
    staleTime: 5 * 60 * 1000,  // 5 minutes
  });
}

export function useProduct(id: string) {
  return useQuery({
    queryKey: ['products', id],
    queryFn: () => productApi.getById(id),
  });
}

export function useCreateProduct() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: productApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });
}
```

---

## Styling

### StyleSheet

```typescript
// src/components/Card.tsx
import { StyleSheet, View, Text, ViewStyle, TextStyle } from 'react-native';

interface CardProps {
  title: string;
  children: React.ReactNode;
  style?: ViewStyle;
}

export function Card({ title, children, style }: CardProps) {
  return (
    <View style={[styles.container, style]}>
      <Text style={styles.title}>{title}</Text>
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#fff',
    borderRadius: 8,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 8,
  },
});
```

### Theme System

```typescript
// src/theme/index.ts
export const theme = {
  colors: {
    primary: '#007AFF',
    secondary: '#5856D6',
    background: '#F2F2F7',
    text: '#000000',
    textSecondary: '#8E8E93',
    border: '#C6C6C8',
    error: '#FF3B30',
    success: '#34C759',
  },
  spacing: {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
  },
  typography: {
    h1: { fontSize: 34, fontWeight: '700' as const },
    h2: { fontSize: 28, fontWeight: '600' as const },
    body: { fontSize: 17, fontWeight: '400' as const },
    caption: { fontSize: 13, fontWeight: '400' as const },
  },
  borderRadius: {
    sm: 4,
    md: 8,
    lg: 16,
    full: 9999,
  },
};

export type Theme = typeof theme;
```

---

## Offline Support

### NetInfo

```typescript
// src/hooks/useNetworkStatus.ts
import { useEffect, useState } from 'react';
import NetInfo, { NetInfoState } from '@react-native-community/netinfo';

export function useNetworkStatus() {
  const [isConnected, setIsConnected] = useState(true);
  const [connectionType, setConnectionType] = useState<string | null>(null);

  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener((state: NetInfoState) => {
      setIsConnected(state.isConnected ?? true);
      setConnectionType(state.type);
    });

    return () => unsubscribe();
  }, []);

  return { isConnected, connectionType };
}
```

### Offline Queue

```typescript
// src/services/offlineQueue.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import NetInfo from '@react-native-community/netinfo';

interface QueuedAction {
  id: string;
  type: string;
  payload: unknown;
  timestamp: number;
}

class OfflineQueue {
  private queue: QueuedAction[] = [];
  private isProcessing = false;

  async enqueue(action: Omit<QueuedAction, 'id' | 'timestamp'>) {
    const queuedAction: QueuedAction = {
      ...action,
      id: generateId(),
      timestamp: Date.now(),
    };

    this.queue.push(queuedAction);
    await this.persist();

    // Try to process immediately if online
    const { isConnected } = await NetInfo.fetch();
    if (isConnected) {
      this.processQueue();
    }
  }

  async processQueue() {
    if (this.isProcessing || this.queue.length === 0) return;

    this.isProcessing = true;

    while (this.queue.length > 0) {
      const action = this.queue[0];

      try {
        await this.executeAction(action);
        this.queue.shift();
        await this.persist();
      } catch (error) {
        console.error('Failed to process action:', error);
        break;
      }
    }

    this.isProcessing = false;
  }

  private async persist() {
    await AsyncStorage.setItem('offline_queue', JSON.stringify(this.queue));
  }

  private async executeAction(action: QueuedAction) {
    // Execute based on action type
    switch (action.type) {
      case 'CREATE_POST':
        return api.createPost(action.payload);
      case 'UPDATE_PROFILE':
        return api.updateProfile(action.payload);
      default:
        throw new Error(`Unknown action type: ${action.type}`);
    }
  }
}

export const offlineQueue = new OfflineQueue();
```

---

## Native Modules

### Using Native Modules

```typescript
// src/services/biometrics.ts
import ReactNativeBiometrics from 'react-native-biometrics';

const rnBiometrics = new ReactNativeBiometrics();

export async function authenticateWithBiometrics(): Promise<boolean> {
  const { available, biometryType } = await rnBiometrics.isSensorAvailable();

  if (!available) {
    throw new Error('Biometrics not available');
  }

  const { success } = await rnBiometrics.simplePrompt({
    promptMessage: 'Confirm your identity',
  });

  return success;
}
```

### Permissions

```typescript
// src/hooks/usePermissions.ts
import { Platform } from 'react-native';
import {
  request,
  check,
  PERMISSIONS,
  RESULTS,
  Permission,
} from 'react-native-permissions';

export async function requestCameraPermission(): Promise<boolean> {
  const permission: Permission = Platform.select({
    ios: PERMISSIONS.IOS.CAMERA,
    android: PERMISSIONS.ANDROID.CAMERA,
  })!;

  const status = await check(permission);

  if (status === RESULTS.GRANTED) {
    return true;
  }

  if (status === RESULTS.DENIED) {
    const result = await request(permission);
    return result === RESULTS.GRANTED;
  }

  return false;
}
```

---

## Performance

### List Optimization

```typescript
// Use FlatList for long lists
import { FlatList } from 'react-native';

function ProductList({ products }) {
  const renderItem = useCallback(
    ({ item }) => <ProductCard product={item} />,
    []
  );

  const keyExtractor = useCallback((item) => item.id, []);

  return (
    <FlatList
      data={products}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      initialNumToRender={10}
      maxToRenderPerBatch={10}
      windowSize={5}
      removeClippedSubviews={true}
      getItemLayout={(data, index) => ({
        length: ITEM_HEIGHT,
        offset: ITEM_HEIGHT * index,
        index,
      })}
    />
  );
}
```

### Image Optimization

```typescript
import FastImage from 'react-native-fast-image';

function ProductImage({ uri }) {
  return (
    <FastImage
      source={{
        uri,
        priority: FastImage.priority.normal,
        cache: FastImage.cacheControl.immutable,
      }}
      style={styles.image}
      resizeMode={FastImage.resizeMode.cover}
    />
  );
}
```

---

## Checklist

Before completing mobile implementation:

- [ ] Navigation typed and configured
- [ ] Platform-specific code handled
- [ ] State management set up
- [ ] Offline support (if needed)
- [ ] Permissions handled gracefully
- [ ] List performance optimized
- [ ] Images cached properly
- [ ] Deep linking configured
- [ ] Push notifications (if needed)
- [ ] Error boundaries added

---

## Related

- `frontend-architecture.md` - Component patterns
- `authentication.md` - Mobile auth flows
- `caching-strategies.md` - Offline caching

---

*Protocol created: 2025-12-08*
*Version: 1.0*
