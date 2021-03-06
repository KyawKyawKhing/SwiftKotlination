package fr.jhandguy.swiftkotlination.features.story.model

import fr.jhandguy.swiftkotlination.observer.Result
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.Before
import org.junit.Test
import org.koin.dsl.module.module
import org.koin.standalone.StandAloneContext.startKoin
import org.koin.standalone.StandAloneContext.stopKoin
import org.koin.standalone.inject
import org.koin.test.KoinTest

class StoryManagerUnitTest: KoinTest {

    val story = Story("section", "subsection", "title", "abstract", "url", "byline")

    val sut: StoryManagerInterface by inject()

    @Before
    fun before() {
        startKoin(listOf(
                module {
                    factory { StoryManager(story) as StoryManagerInterface }
                }
        ))
    }

    @Test
    fun `story is injected correctly`() {
        runBlocking {
            sut
                    .story { result ->
                        when(result) {
                            is Result.Success -> assertEquals(result.data, story)
                            is Result.Failure -> fail(result.error.message)
                        }
                    }
        }
    }

    @After
    fun after() {
        stopKoin()
    }
}