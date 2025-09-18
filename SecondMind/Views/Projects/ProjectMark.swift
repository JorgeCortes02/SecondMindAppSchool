//
//  ProjectMark.swift
//  SecondMind
//
//  Created by Jorge Cortés on 20/6/25.
//

import SwiftUI
import SwiftData
import Foundation
import UIKit
struct ProjectMark: View {
    
   
    @EnvironmentObject var  utilFunctions : generalFunctions
    @Environment(\.modelContext) private var context
   
    
    @State private var readyToShowTasks: Bool = false
    
    private let accentColor = Color(red: 160/255, green: 130/255, blue: 180/255)
    @State private var showAddProjectView: Bool = false

    @State private var selectedTab: Int = 0
    
    @State private var projectList: [Project] = []
    
    
    var body: some View {
        VStack(spacing: 20) {
            headerCard(title: "Proyectos").padding(.top, 16)
            pickerBard

            ScrollView {
                VStack(spacing: 20) {

                    if projectList.isEmpty {
                        emptyProjectList
                    }else{
                        showProjectList
                    }
                    
                }
                .padding(.vertical, 16)
            }
        }
        .safeAreaInset(edge: .bottom) {
            // 👇 Botón flotante bien colocado, no tapa el contenido
            HStack {
                Spacer()
                buttonControlMark
            }
            .padding(.trailing, 16)
            .padding(.bottom, 80)
        }.sheet(isPresented: $showAddProjectView, onDismiss: {
            withAnimation(.easeInOut(duration: 0.2)) {
                
               
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        readyToShowTasks = true
                    }
                    
                }}
        }){
            CreateProject()
        }.onAppear{
            if selectedTab == 1 {
                projectList = []
                projectList =  HomeApi.downloadOffProjects(context: context)
            }else{
                projectList = HomeApi.downloadOnProjects(context: context)
            }
        }.onChange(of: selectedTab){
            if selectedTab == 1 {
                projectList = []
                projectList =  HomeApi.downloadOffProjects(context: context)
            }else{
                projectList = HomeApi.downloadOnProjects(context: context)
            }
            
        }
        .ignoresSafeArea(.keyboard)
    }
    
 

    // MARK: – Botón para cada segmento
    private func segmentButton(title: String, tag: Int) -> some View {
        let isSelected = (selectedTab == tag)
        return Button(action: {
            withAnimation(.easeInOut) {
                selectedTab = tag
            }
        }) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .taskButtonColor)
                .frame( maxHeight: 36).frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.taskButtonColor)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.clear)
                           
                               
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: – Tarjeta con el DatePicker
  
    
    private var pickerBard : some View {
        // — Segmented control personalizado —
        HStack(spacing: 10) {
            segmentButton(title: "Activos", tag: 0)
            segmentButton(title: "Finalizados", tag: 1)
        }.padding(15) .background(Color.cardBackground)
            
            .cornerRadius(40)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 16)
        
        
    }
    
    private var buttonControlMark: some View {
        
        HStack(spacing: 10) {
      
            if #available(iOS 26.0, *) {
                Button(action: {
                    showAddProjectView = true
                }) {
                    Image(systemName: "plus")
                        
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.taskButtonColor)
                        .padding(16)
                    
                }
                .glassEffect(.regular.tint(Color.white.opacity(0.1)).interactive(), in: .circle)
                .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 4)
                
                
            } else {
                
                Button(action: {
                    showAddProjectView = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                    
                        .background(
                            Circle()
                                .fill(Color.taskButtonColor.opacity(0.9))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                }}

            
            
            
         
            
        }.padding(10)
            
            .background(
                Capsule()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
            ).padding(.bottom, 60)
        
    }
    
   
    
    private var emptyProjectList: some View {
        print(projectList)
        return
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "folder")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 90)
                .foregroundColor(accentColor.opacity(0.7))

            Text("No hay proyectos disponibles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding(20)
    }
    
   private var showProjectList: some View {
        
       print(projectList)
       let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
       ]
       
       return LazyVGrid(columns: columns, spacing: 30){
          
           ForEach(projectList, id : \.self){ project in
               NavigationLink(destination: ProjectDetall(editableProject : project))
               {
                   ZStack(alignment: .topLeading) {
                       RoundedRectangle(cornerRadius: 8)
                           .fill(Color.purple)
                           .frame(width: 90, height: 30)
                           .offset(x: 10, y: -7).shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                           .overlay(
                               RoundedRectangle(cornerRadius: 16)
                                   .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
                           )
                       projectElement(project: project)
                       
               }
                   // Solapa siempre encima
                  
               }
               
                
               
               
           }
           
           
       }.padding()
       
    }
    
    
    
    private func projectElement(project: Project) -> some View {
        
        
        
        VStack(alignment: .leading, spacing: 8) {
                
            HStack(){
                Image(systemName: "folder").font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.taskButtonColor)
                    .padding(.bottom, 4)

                Text(project.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.taskButtonColor)
                    .padding(.bottom, 4).lineLimit(1)

                
            }.padding().padding(.bottom, 0).frame(maxWidth: .infinity).background(Color(red: 228/255, green: 214/255, blue: 244/255)).cornerRadius(16, corners: [.topLeft, .topRight])

       
            // Métricas del proyecto
            VStack(alignment: .leading, spacing: 10) {
                
                Label("Próximo evento: ", systemImage: "calendar.badge.clock").foregroundStyle(Color.black)
                
              
                    Text("\(firtsEvent(events: project.events))")
                    .frame(maxWidth: .infinity, alignment: .center)
            
                Label("\(project.events.filter { $0.status == .on }.count) eventos activos", systemImage: "calendar").foregroundStyle(Color.eventButtonColor)
                Label("\(project.tasks.filter { $0.status == .on }.count) tareas activas", systemImage: "checkmark.circle.fill").foregroundStyle(Color.taskButtonColor)
            }.padding().padding(.top, 0)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color(red: 242/255, green: 242/255, blue: 242/255), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple, lineWidth: 0.5)
        )
    }
    
    
    private func firtsEvent(events : [Event]) -> String {
        
       let today = Date()
        
        var futureEvents = events.filter { $0.endDate > today }
        
        var firtsEvent =  futureEvents.min(by: {$0.endDate < $1.endDate})
        
        if let date = firtsEvent?.endDate{
            return utilFunctions.formattedDateAndHour(date)
        }
        
        return "No hay eventos"
    }
    
        }
        
        
       
       
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

/// Extensión para poder llamar .cornerRadius(_:corners:)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
