//
//  NotesView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-14.
//

import SwiftUI
import CoreData
import FirebaseAnalytics

struct NotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.creationDate, ascending: false)],
        animation: .default)
    private var notes: FetchedResults<Note>
    
    @State private var showingAddNote = false
    @State private var showingEditNote = false
    @State private var selectedNote: Note? = nil
    
    @State private var screenEnterTime: Date?
    @State private var lastActionTime: Date?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#ddead1")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if notes.isEmpty {
                        // No Notes
                        Text("No notes yet")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            HStack {
                                Text("Notes")
                                    .foregroundColor(.black)
                                    .font(.system(size: 17)).bold()
                                    .padding(.horizontal, 13)
                                Spacer()
                            }
                            
                            ForEach(notes) { note in
                                Button {
                                    logNoteTap()
                                    selectedNote = note
                                    showingEditNote = true
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(note.name ?? "Name note")
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
                                    .background(Color(hex: "#546a50").opacity(0.000000001))
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
                                .onAppear {
                                    Analytics.logEvent("notes_edit_note_opened", parameters: [
                                        "note_name_length": note.name?.count ?? 0,
                                        "note_text_length": note.text?.count ?? 0
                                    ])
                                    updateLastAction()
                                }
                        }
                    }
                }
                
                // Add Note Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            logAddNoteTap()
                            showingAddNote = true
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 60, height: 60)
                                .background(Color(hex: "FBDA4B"))
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
                        }
                        .padding(.bottom, 85)
                        .padding(.trailing, 20)
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView()
                    .environment(\.managedObjectContext, viewContext)
                    .onAppear {
                        Analytics.logEvent("notes_add_note_opened", parameters: nil)
                        updateLastAction()
                    }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            screenEnterTime = Date()
            lastActionTime = Date()
            Analytics.logEvent("notes_screen_appear", parameters: nil)
        }
        .onDisappear {
            if let enter = screenEnterTime {
                let duration = Date().timeIntervalSince(enter)
                Analytics.logEvent("notes_screen_disappear", parameters: [
                    "duration_seconds": duration
                ])
            }
        }
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func logAddNoteTap() {
        logAction(event: "notes_add_note_button_tap")
    }
    
    private func logNoteTap() {
        logAction(event: "notes_existing_note_tap")
    }
    
    private func logAction(event: String) {
        let now = Date()
        if let last = lastActionTime {
            let interval = now.timeIntervalSince(last)
            Analytics.logEvent(event, parameters: [
                "interval_since_last_action": interval
            ])
        } else {
            Analytics.logEvent(event, parameters: nil)
        }
        lastActionTime = now
    }
    
    private func updateLastAction() {
        lastActionTime = Date()
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        let exampleNote1 = Note(context: context)
        exampleNote1.name = "example note 1"
        exampleNote1.text = "Пример заметки номер один. Длинный текст."
        exampleNote1.creationDate = Date()

        let exampleNote2 = Note(context: context)
        exampleNote2.name = "example note 2"
        exampleNote2.text = "Вторая заметка – покороче."
        exampleNote2.creationDate = Date().addingTimeInterval(-3600)

        return NotesView()
            .environment(\.managedObjectContext, context)
    }
}


/*
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
                Color(hex: "#ddead1")
                    .ignoresSafeArea()
            
                
                    VStack(spacing: 0) {
                        
                        // List of notes
                        if notes.isEmpty {
                            
                            // No Notes
                         
                        } else {
                            ScrollView {
                                HStack {
                                    Text("Notes")
                                        .foregroundColor(.black)
                                        .font(.system(size: 17)).bold()
                                        .padding(.horizontal, 13)
                                      
                                    
                                    Spacer()
                                }
                                
                                ForEach(notes) { note in
                                    Button {
                                        selectedNote = note
                                        showingEditNote = true
                                    } label: {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(note.name ?? "Name note")
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
                                        .background(Color(hex: "#546a50").opacity(0.000000001))
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
                            Button {
                                showingAddNote = true
                                
                                // Вибрация
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(width: 60, height: 60)
                                    .background(Color(hex: "FBDA4B"))
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
                            }
                            .padding(.bottom, 85)
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
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        // Добавим пример данных для превью
        let exampleNote1 = Note(context: context)
        exampleNote1.name = "example note 1"
        exampleNote1.text = "Пример заметки номер один. Она может быть длинной, но обрежется на 3 строки.Пример заметки номер один. Она может быть длинной, но обрежется на 3 строки.Пример заметки номер один. Она может быть длинной, но обрежется на 3 строки."
        exampleNote1.creationDate = Date()

        let exampleNote2 = Note(context: context)
        exampleNote2.name = "example note 2"
        exampleNote2.text = "Вторая заметка – покороче."
        exampleNote2.creationDate = Date().addingTimeInterval(-3600)

        return NotesView()
            .environment(\.managedObjectContext, context)
    }
}
*/
