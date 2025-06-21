//
//  NotesView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-14.
//

import SwiftUI
import CoreData

struct NotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.creationDate, ascending: false)],
        animation: .default)
    private var notes: FetchedResults<Note>
    
    @State private var showingAddNote = false
    @State private var showingEditNote = false
    @State private var selectedNote: Note? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    
                    // List of notes
                    if notes.isEmpty {
                        
                        // No Notes
                        Image("no_notes_image")
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .padding(.bottom, 100)
                            .shadow(radius: 40)
                        
                    } else {
                        ScrollView {
                            ForEach(notes) { note in
                                Button {
                                    selectedNote = note
                                    showingEditNote = true
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(note.text ?? "")
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.bottom, 60)
                                        
                                        HStack {
                                            Image(systemName: "calendar")
                                                .foregroundColor(.gray)
                                            
                                            Text(formattedDate(note.creationDate))
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 150)
                                    .background(Color(hex: "#546a50").opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "#546a50").opacity(0.2), lineWidth: 8)
                                    )
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .sheet(item: $selectedNote) { note in
                            EditNoteView(note: note)
                                .environment(\.managedObjectContext, viewContext)
                        }
                    }
                }
                
                // Add Note Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddNote = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 60, height: 60)
                                .background(Color(hex: "#E6A7FA")) // PINK HEX
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
                        }
                        .padding(.bottom, 30)
                        .padding(.trailing, 20)
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .navigationBarHidden(true)
        }
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        // Добавим пример данных для превью
        let exampleNote1 = Note(context: context)
        exampleNote1.text = "Пример заметки номер один. Она может быть длинной, но обрежется на 3 строки.Пример заметки номер один. Она может быть длинной, но обрежется на 3 строки.Пример заметки номер один. Она может быть длинной, но обрежется на 3 строки."
        exampleNote1.creationDate = Date()

        let exampleNote2 = Note(context: context)
        exampleNote2.text = "Вторая заметка – покороче."
        exampleNote2.creationDate = Date().addingTimeInterval(-3600)

        return NotesView()
            .environment(\.managedObjectContext, context)
    }
}
