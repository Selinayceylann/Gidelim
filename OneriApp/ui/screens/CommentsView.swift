//
//  CommentsView.swift
//  OneriApp
//
//  Created by selinay ceylan on 9.11.2025.
//

import SwiftUI

struct CommentsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        ZStack {
            backgroundView
            contentView
        }
        .navigationTitle("Yorumlarım")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Main Content
private extension CommentsView {
    var backgroundView: some View {
        Color(red: 0.95, green: 0.95, blue: 0.97)
            .ignoresSafeArea()
    }
    
    var contentView: some View {
        Group {
            if let comments = viewModel.currentUser?.comments, !comments.isEmpty {
                commentsList(comments: comments)
            } else {
                emptyStateView
            }
        }
    }
    
    func commentsList(comments: [Review]) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(comments) { comment in
                    CommentCard(comment: comment, onDelete: {
                        Task {
                            await viewModel.deleteComment(commentId: comment.id!)
                        }
                    })
                }
            }
            .padding()
        }
    }
    
    var emptyStateView: some View {
        EmptyStateView(
            icon: "bubble.left.and.bubble.right",
            title: "Henüz yorum yapmadın",
            subtitle: "Gittiğin mekanlar hakkında yorum yap"
        )
    }
}

// MARK: - Comment Card
struct CommentCard: View {
    let comment: Review
    let onDelete: () -> Void
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            commentText
            deleteButton
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .alert("Yorumu Sil", isPresented: $showDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Bu yorumu silmek istediğinize emin misiniz?")
        }
    }
}

// MARK: - Comment Card Components
private extension CommentCard {
    var headerSection: some View {
        HStack {
            userInfoSection
            Spacer()
            ratingBadge
        }
    }
    
    var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(comment.userName ?? "")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let date = comment.date {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    var ratingBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text(String(format: "%.1f", comment.rating ?? 0.0))
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(8)
    }
    
    var commentText: some View {
        Text(comment.comment ?? "")
            .font(.body)
            .foregroundColor(.primary)
            .lineLimit(nil)
    }
    
    var deleteButton: some View {
        HStack {
            Spacer()
            Button(action: {
                showDeleteAlert = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                    Text("Sil")
                }
                .font(.subheadline)
                .foregroundColor(.red)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 20) {
            iconSection
            titleSection
            subtitleSection
        }
        .padding()
    }
}

// MARK: - Empty State Components
private extension EmptyStateView {
    var iconSection: some View {
        Image(systemName: icon)
            .font(.system(size: 64))
            .foregroundColor(.gray.opacity(0.5))
    }
    
    var titleSection: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
    
    var subtitleSection: some View {
        Text(subtitle)
            .font(.subheadline)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
    }
}

// MARK: - Stat View
struct StatView: View {
    let number: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            numberSection
            labelSection
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stat View Components
private extension StatView {
    var numberSection: some View {
        Text(number)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.primary)
    }
    
    var labelSection: some View {
        Text(label)
            .font(.caption)
            .foregroundColor(.gray)
    }
}

// MARK: - Menu Button
struct MenuButton: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var isDestructive: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16) {
                iconSection
                textSection
                Spacer()
                chevronIcon
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Menu Button Components
private extension MenuButton {
    var iconSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(iconColor.opacity(0.15))
                .frame(width: 50, height: 50)
            
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
        }
    }
    
    var textSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isDestructive ? .red : .primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 14))
            .foregroundColor(.gray.opacity(0.5))
    }
}
