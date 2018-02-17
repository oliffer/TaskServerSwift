//
//  TasksControllerTests.swift
//  TaskerServerLibTests
//
//  Created by Marcin Czachurski on 15.02.2018.
//

import Foundation

import XCTest
import PerfectHTTP
import Dobby
@testable import TaskerServerLib

class TasksControllerTests: XCTestCase {
    
    func testInitRoutesShouldInitializeGetAllTasksRoute() {
        
        // Arrange.
        let fakeHttpRequest = FakeHTTPRequest(method: .get)
        let fakeTasksRepository = FakeTasksRepository()
        
        // Act.
        let tasksController = TasksController(tasksRepository: fakeTasksRepository)
        
        // Assert.
        let requestHandler = tasksController.routes.navigator.findHandler(uri: "/tasks", webRequest: fakeHttpRequest)
        XCTAssertNotNil(requestHandler)
    }
    
    func testInitRoutesShouldInitializeGetTaskByIdRoute() {
        
        // Arrange.
        let fakeHttpRequest = FakeHTTPRequest(method: .get)
        let fakeTasksRepository = FakeTasksRepository()
        
        // Act.
        let tasksController = TasksController(tasksRepository: fakeTasksRepository)
        
        // Assert.
        let requestHandler = tasksController.routes.navigator.findHandler(uri: "/tasks/123", webRequest: fakeHttpRequest)
        XCTAssertNotNil(requestHandler)
    }
    
    func testInitRoutesShouldInitializePostTaskRoute() {
        
        // Arrange.
        let fakeHttpRequest = FakeHTTPRequest(method: .post)
        let fakeTasksRepository = FakeTasksRepository()
        
        // Act.
        let tasksController = TasksController(tasksRepository: fakeTasksRepository)
        
        // Assert.
        let requestHandler = tasksController.routes.navigator.findHandler(uri: "/tasks", webRequest: fakeHttpRequest)
        XCTAssertNotNil(requestHandler)
    }
    
    func testInitRoutesShouldInitializePutTaskRoute() {
        
        // Arrange.
        let fakeHttpRequest = FakeHTTPRequest(method: .put)
        let fakeTasksRepository = FakeTasksRepository()
        
        // Act.
        let tasksController = TasksController(tasksRepository: fakeTasksRepository)
        
        // Assert.
        let requestHandler = tasksController.routes.navigator.findHandler(uri: "/tasks/123", webRequest: fakeHttpRequest)
        XCTAssertNotNil(requestHandler)
    }
    
    func testInitRoutesShouldInitializeDeleteTaskRoute() {
        
        // Arrange.
        let fakeHttpRequest = FakeHTTPRequest(method: .delete)
        let fakeTasksRepository = FakeTasksRepository()
        
        // Act.
        let tasksController = TasksController(tasksRepository: fakeTasksRepository)
        
        // Assert.
        let requestHandler = tasksController.routes.navigator.findHandler(uri: "/tasks/123", webRequest: fakeHttpRequest)
        XCTAssertNotNil(requestHandler)
    }
    
    func testGetTasksShouldReturnTasksCollection() {
        
        // Arrange.
        let fakeHttpRequest = FakeHTTPRequest()
        let fakeHttpResponse = FakeHTTPResponse()
        let fakeTasksRepository = FakeTasksRepository()
        
        fakeTasksRepository.getTasksMock.expect(any())
        fakeTasksRepository.getTasksStub.on(any(), return: [
            Task(id: 1, name: "Create unit tests", isFinished: false),
            Task(id: 2, name: "Create article", isFinished: true)
            ])
        let tasksController = TasksController(tasksRepository: fakeTasksRepository)
        
        // Act.
        tasksController.getTasks(request: fakeHttpRequest, response: fakeHttpResponse)
        
        // Assert.
        let tasks = try! fakeHttpResponse.getObjectFromResponseBody(Array<Task>.self)
        fakeTasksRepository.getTasksMock.verify()
        XCTAssertEqual(HTTPResponseStatus.ok.code, fakeHttpResponse.status.code)
        XCTAssertEqual(2, tasks.count)
        XCTAssertEqual("Create unit tests", tasks[0].name)
        XCTAssertEqual("Create article", tasks[1].name)
    }
    
    func testGetTaskShouldReturnTaskWhenWeProvideCorrectId() {
        
        // Arrange.
        let fakeHttpRequest = FakeHTTPRequest(urlVariables: ["id": "1"])
        let fakeHttpResponse = FakeHTTPResponse()
        let fakeTasksRepository = FakeTasksRepository()
        
        fakeTasksRepository.getTaskMock.expect(any())
        fakeTasksRepository.getTaskStub.on(equals(1), return:
            Task(id: 1, name: "Create unit tests", isFinished: false)
        )
        let tasksController = TasksController(tasksRepository: fakeTasksRepository)
        
        // Act.
        tasksController.getTask(request: fakeHttpRequest, response: fakeHttpResponse)
        
        // Assert.
        let task = try! fakeHttpResponse.getObjectFromResponseBody(Task.self)
        fakeTasksRepository.getTaskMock.verify()
        XCTAssertEqual(HTTPResponseStatus.ok.code, fakeHttpResponse.status.code)
        XCTAssertEqual(1, task.id)
        XCTAssertEqual("Create unit tests", task.name)
    }
    
    func testGetTaskShouldReturnNotFoundStatusCodeWhenWeProvideIncorrectId() {
        
        // Arrange.
        let fakeHttpRequest = FakeHTTPRequest(urlVariables: ["id": "2"])
        let fakeHttpResponse = FakeHTTPResponse()
        let fakeTasksRepository = FakeTasksRepository()
        
        fakeTasksRepository.getTaskMock.expect(any())
        fakeTasksRepository.getTaskStub.on(equals(2), return: nil)
        let tasksController = TasksController(tasksRepository: fakeTasksRepository)
        
        // Act.
        tasksController.getTask(request: fakeHttpRequest, response: fakeHttpResponse)
        
        // Assert.
        XCTAssertEqual(HTTPResponseStatus.notFound.code, fakeHttpResponse.status.code)
    }
    
    func testPostTaskShouldAddTaskToStoreWhenWeProvideCorrectTaskData() {
        
        // Arrange.
        let fakeHttpRequest = FakeHTTPRequest()
        let fakeHttpResponse = FakeHTTPResponse()
        let fakeTasksRepository = FakeTasksRepository()
        
        fakeHttpRequest.addObjectToRequestBody(Task(id: 1, name: "Create unit tests", isFinished: true))
        fakeTasksRepository.addTaskMock.expect(matches({(task) -> Bool in
            task.id == 1 && task.name == "Create unit tests" && task.isFinished == true
        }))
        
        let tasksController = TasksController(tasksRepository: fakeTasksRepository)
        
        // Act.
        tasksController.postTask(request: fakeHttpRequest, response: fakeHttpResponse)
        
        // Assert.
        XCTAssertEqual(HTTPResponseStatus.ok.code, fakeHttpResponse.status.code)
        fakeTasksRepository.addTaskMock.verify()
    }
    
    func testPostTaskShouldReturnBadRequestStatusCodeWhenWeNotProvideJson() {
        
        // Arrange.
        let fakeHttpRequest = FakeHTTPRequest()
        let fakeHttpResponse = FakeHTTPResponse()
        let fakeTasksRepository = FakeTasksRepository()
        let tasksController = TasksController(tasksRepository: fakeTasksRepository)
        
        // Act.
        tasksController.postTask(request: fakeHttpRequest, response: fakeHttpResponse)
        
        // Assert.
        XCTAssertEqual(HTTPResponseStatus.badRequest.code, fakeHttpResponse.status.code)
    }
    
    func testPutTaskShouldUpdateUserInStoreWhenWeProvideCorrectTaskData() {
        
        // Arrange.
        let fakeHttpRequest = FakeHTTPRequest(urlVariables: ["id": "1"])
        let fakeHttpResponse = FakeHTTPResponse()
        let fakeTasksRepository = FakeTasksRepository()
        
        fakeHttpRequest.addObjectToRequestBody(Task(id: 1, name: "Create unit tests", isFinished: true))
        fakeTasksRepository.updateTaskMock.expect(matches({(task) -> Bool in
            task.id == 1 && task.name == "Create unit tests" && task.isFinished == true
        }))
        
        let tasksController = TasksController(tasksRepository: fakeTasksRepository)
        
        // Act.
        tasksController.putTask(request: fakeHttpRequest, response: fakeHttpResponse)
        
        // Assert.
        XCTAssertEqual(HTTPResponseStatus.ok.code, fakeHttpResponse.status.code)
        fakeTasksRepository.addTaskMock.verify()
    }
    
    func testPutTaskShouldReturnBadRequestStatusCodeWhenWeNotProvideJson() {
        
        // Arrange.
        let fakeHttpRequest = FakeHTTPRequest()
        let fakeHttpResponse = FakeHTTPResponse()
        let fakeTasksRepository = FakeTasksRepository()
        let tasksController = TasksController(tasksRepository: fakeTasksRepository)
        
        // Act.
        tasksController.putTask(request: fakeHttpRequest, response: fakeHttpResponse)
        
        // Assert.
        XCTAssertEqual(HTTPResponseStatus.badRequest.code, fakeHttpResponse.status.code)
    }
    
    func testDeleteTaskShouldDeleteTaskFromStoreWhenWeProvideCorrectUserId() {
        
        // Arrange.
        let fakeHttpRequest = FakeHTTPRequest(urlVariables: ["id": "1"])
        let fakeHttpResponse = FakeHTTPResponse()
        let fakeTasksRepository = FakeTasksRepository()
        
        fakeTasksRepository.deleteTaskMock.expect(matches({(id) -> Bool in id == 1 }))
        let tasksController = TasksController(tasksRepository: fakeTasksRepository)
        
        // Act.
        tasksController.deleteTask(request: fakeHttpRequest, response: fakeHttpResponse)
        
        // Assert.
        XCTAssertEqual(HTTPResponseStatus.ok.code, fakeHttpResponse.status.code)
        fakeTasksRepository.deleteTaskMock.verify()
    }
    
    func testDeleteTaskShouldReturnNotFoundStatusCodeWhenWeNotProvideCorrectId() {
        
        // Arrange.
        let fakeHttpRequest = FakeHTTPRequest()
        let fakeHttpResponse = FakeHTTPResponse()
        let fakeTasksRepository = FakeTasksRepository()
        let tasksController = TasksController(tasksRepository: fakeTasksRepository)
        
        // Act.
        tasksController.deleteTask(request: fakeHttpRequest, response: fakeHttpResponse)
        
        // Assert.
        XCTAssertEqual(HTTPResponseStatus.notFound.code, fakeHttpResponse.status.code)
    }
    
    static var allTests = [
        ("testInitRoutesShouldInitializeGetAllTasksRoute", testInitRoutesShouldInitializeGetAllTasksRoute),
        ("testInitRoutesShouldInitializeGetTaskByIdRoute", testInitRoutesShouldInitializeGetTaskByIdRoute),
        ("testInitRoutesShouldInitializePostTaskRoute", testInitRoutesShouldInitializePostTaskRoute),
        ("testInitRoutesShouldInitializePutTaskRoute", testInitRoutesShouldInitializePutTaskRoute),
        ("testInitRoutesShouldInitializeDeleteTaskRoute", testInitRoutesShouldInitializeDeleteTaskRoute),
        ("testGetTasksShouldReturnTasksCollection", testGetTasksShouldReturnTasksCollection),
        ("testGetTaskShouldReturnTaskWhenWeProvideCorrectId", testGetTaskShouldReturnTaskWhenWeProvideCorrectId),
        ("testGetTaskShouldReturnNotFoundStatusCodeWhenWeProvideIncorrectId", testGetTaskShouldReturnNotFoundStatusCodeWhenWeProvideIncorrectId),
        ("testPostTaskShouldAddTaskToStoreWhenWeProvideCorrectTaskData", testPostTaskShouldAddTaskToStoreWhenWeProvideCorrectTaskData),
        ("testPostTaskShouldReturnBadRequestStatusCodeWhenWeNotProvideJson", testPostTaskShouldReturnBadRequestStatusCodeWhenWeNotProvideJson),
        ("testPutTaskShouldUpdateUserInStoreWhenWeProvideCorrectTaskData", testPutTaskShouldUpdateUserInStoreWhenWeProvideCorrectTaskData),
        ("testPutTaskShouldReturnBadRequestStatusCodeWhenWeNotProvideJson", testPutTaskShouldReturnBadRequestStatusCodeWhenWeNotProvideJson),
        ("testDeleteTaskShouldDeleteTaskFromStoreWhenWeProvideCorrectUserId", testDeleteTaskShouldDeleteTaskFromStoreWhenWeProvideCorrectUserId),
        ("testDeleteTaskShouldReturnNotFoundStatusCodeWhenWeNotProvideCorrectId", testDeleteTaskShouldReturnNotFoundStatusCodeWhenWeNotProvideCorrectId)
    ]
}