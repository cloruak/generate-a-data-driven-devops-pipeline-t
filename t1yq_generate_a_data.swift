//
//  t1yq_generate_a_data.swift
//  Generate a Data-Driven DevOps Pipeline Tracker
//

import Foundation
import CoreData

// Data Model
struct PipelineTracker {
    let pipelineID: UUID
    let pipelineName: String
    let stages: [PipelineStage]
}

struct PipelineStage {
    let stageID: UUID
    let stageName: String
    let status: String // (e.g., "pending", "in_progress", "completed")
    let startTime: Date?
    let endTime: Date?
}

// Core Data Stack
let dataStack = CoreDataStack(modelName: "PipelineTracker")

// Data Access
func fetchAllPipelines() -> [PipelineTracker] {
    let fetchRequest: NSFetchRequest<PipelineTrackerEntity> = PipelineTrackerEntity.fetchRequest()
    do {
        let pipelineEntities = try dataStack.mainContext.fetch(fetchRequest)
        return pipelineEntities.compactMap { PipelineTracker(from: $0) }
    } catch {
        print("Error fetching pipelines: \(error)")
        return []
    }
}

func createPipeline(_ pipeline: PipelineTracker) {
    let pipelineEntity = PipelineTrackerEntity(context: dataStack.mainContext)
    pipelineEntity.pipelineID = pipeline.pipelineID
    pipelineEntity.pipelineName = pipeline.pipelineName
    pipelineEntity.stages = pipeline.stages.compactMap { PipelineStageEntity(from: $0) }
    do {
        try dataStack.mainContext.save()
    } catch {
        print("Error creating pipeline: \(error)")
    }
}

// Pipeline Tracker View Model
class PipelineTrackerViewModel {
    @Published var pipelines: [PipelineTracker] = []
    
    init() {
        fetchPipelines()
    }
    
    func fetchPipelines() {
        pipelines = fetchAllPipelines()
    }
    
    func createPipeline(_ pipeline: PipelineTracker) {
        createPipeline(pipeline)
        fetchPipelines()
    }
}

// Example Usage
let viewModel = PipelineTrackerViewModel()

let pipeline = PipelineTracker(pipelineID: UUID(), pipelineName: "My Pipeline", stages: [
    PipelineStage(stageID: UUID(), stageName: "Build", status: "pending", startTime: nil, endTime: nil),
    PipelineStage(stageID: UUID(), stageName: "Test", status: "pending", startTime: nil, endTime: nil),
    PipelineStage(stageID: UUID(), stageName: "Deploy", status: "pending", startTime: nil, endTime: nil)
])

viewModel.createPipeline(pipeline)

print(viewModel.pipelines)