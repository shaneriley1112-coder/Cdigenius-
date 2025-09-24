import React, { useEffect, useState } from 'react';
import { View, Text, Button, Alert } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as InAppPurchases from 'expo-in-app-purchases';
import axios from 'axios';

export default function App() {
  const [isPro, setIsPro] = useState(false);
  const [checking, setChecking] = useState(false);
  const SERVER_URL = 'https://YOUR_SERVER_URL/verify-subscription';
  const SUBSCRIPTION_ID = 'com.cdigenius.pro_monthly';

  useEffect(() => {
    InAppPurchases.connectAsync();
    const listener = InAppPurchases.setPurchaseListener(async ({ responseCode, results }) => {
      if (responseCode === InAppPurchases.IAPResponseCode.OK) {
        for (const purchase of results) {
          if (!purchase.acknowledged) {
            await handlePurchase(purchase);
            await InAppPurchases.finishTransactionAsync(purchase, false);
          }
        }
      }
    });
    checkStoredSubscription();
    return () => {
      InAppPurchases.disconnectAsync();
      listener.remove();
    };
  }, []);

  async function handlePurchase(purchase) {
    const purchaseToken = purchase.purchaseToken;
    const MAX_RETRIES = 3;
    let attempts = 0;
    let verified = false;
    while (attempts < MAX_RETRIES && !verified) {
      try {
        setChecking(true);
        const response = await axios.post(SERVER_URL, {
          packageName: 'com.cdigenius',
          subscriptionId: SUBSCRIPTION_ID,
          purchaseToken,
        });
        if (response.data.valid) {
          setIsPro(true);
          await AsyncStorage.setItem('purchaseToken', purchaseToken);
          Alert.alert('Success', 'Pro features unlocked!');
        } else {
          setIsPro(false);
          await AsyncStorage.removeItem('purchaseToken');
          Alert.alert('Notice', 'Subscription invalid or expired.');
        }
        verified = true;
      } catch (error) {
        attempts++;
        await new Promise(resolve => setTimeout(resolve, 2000));
        if (attempts >= MAX_RETRIES) Alert.alert('Error', 'Failed to verify subscription. Try again later.');
      } finally { setChecking(false); }
    }
  }

  async function checkStoredSubscription() {
    const storedToken = await AsyncStorage.getItem('purchaseToken');
    if (storedToken) handlePurchase({ purchaseToken: storedToken });
  }

  async function initiatePurchase() { await InAppPurchases.purchaseItemAsync(SUBSCRIPTION_ID); }

  return (
    <View style={{ flex:1, justifyContent:'center', alignItems:'center' }}>
      <Text style={{ fontSize:24, marginBottom:20 }}>CDI Genius</Text>
      {checking ? <Text style={{ fontSize:16, color:'gray' }}>Checking subscription...</Text>
      : isPro ? <Text style={{ fontSize:18, color:'blue' }}>Pro Features Unlocked ⚡</Text>
      : <Button title="Upgrade to Pro" onPress={initiatePurchase} />}
    </View>
  );
}