import 'package:appletech/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppleTech Core Improvements Tests', () {
    test('Promo Code validations and discount calculations', () {
      final store = AppStore();
      
      // Ensure initial state is clean
      expect(store.appliedPromoCode, isNull);
      expect(store.discount, equals(0));
      
      // Populate cart with some products
      final product = store.products.first;
      final variant = product.variants.first;
      
      store.addToBag(product, variant);
      expect(store.bag.length, equals(1));
      
      final originalSubtotal = store.subtotal;
      expect(originalSubtotal, equals(variant.price));
      
      // Test APPLE10 promo code (10% off)
      final success10 = store.applyPromoCode('APPLE10');
      expect(success10, isTrue);
      expect(store.appliedPromoCode, equals('APPLE10'));
      expect(store.discount, equals((originalSubtotal * 0.1).round()));
      
      // Test invalid promo code
      final successInvalid = store.applyPromoCode('INVALID_CODE');
      expect(successInvalid, isFalse);
      expect(store.appliedPromoCode, equals('APPLE10')); // Remains APPLE10
      
      // Clear promo code
      store.clearPromoCode();
      expect(store.appliedPromoCode, isNull);
      expect(store.discount, equals(0));
      
      // Test WELCOME promo code ($20 off, capped by subtotal)
      final successWelcome = store.applyPromoCode('WELCOME');
      expect(successWelcome, isTrue);
      expect(store.appliedPromoCode, equals('WELCOME'));
      expect(store.discount, equals(20)); // Capped at $20
    });

    test('Review Submission updates product rating and review count reactively', () {
      final store = AppStore();
      final product = store.products.first;
      final originalRating = product.rating;
      final originalReviewCount = product.reviewCount;
      
      // Submit a new high-rating review
      final review = Review(
        id: 'rev-test',
        author: 'Tester',
        rating: 5,
        title: 'Outstanding!',
        content: 'Absolutely incredible performance and premium feel.',
        date: DateTime.now(),
        verified: true,
      );
      
      store.addReview(product.id, review);
      
      // Fetch updated product from store
      final updatedProduct = store.productById(product.id);
      expect(updatedProduct.reviewCount, equals(originalReviewCount + 1));
      expect(updatedProduct.reviews.first.id, equals('rev-test'));
      
      // Verify rating recalculation
      final expectedRating = double.parse(
        ((originalRating * originalReviewCount + 5) / (originalReviewCount + 1)).toStringAsFixed(1)
      );
      expect(updatedProduct.rating, equals(expectedRating));
    });

    test('Virtual Wallet operations add and remove cards reactively', () {
      final store = AppStore();
      final initialCount = store.cards.length;
      
      final newCard = PaymentCard(
        id: 'card-test-id',
        cardholderName: 'Test Holder',
        cardNumber: '•••• •••• •••• 9999',
        expiryDate: '11/30',
        cvv: '123',
        brand: 'Apple Card',
        themeColor: const Color(0xFF1F1F1F),
      );
      
      store.addCard(newCard);
      expect(store.cards.length, equals(initialCount + 1));
      expect(store.cards.last.id, equals('card-test-id'));
      
      store.removeCard('card-test-id');
      expect(store.cards.length, equals(initialCount));
    });
  });
}
